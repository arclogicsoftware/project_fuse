create or replace package body fuse as

procedure log_response (
   p_response clob) is 
   pragma autonomous_transaction;
begin
   insert into api_response (response) values (p_response);
   commit;
exception
   when others then
      rollback;
      raise_application_error(-20000, 'log_response: '||sqlerrm);
end;

procedure init is 
begin
   fuse.last_response_json := null;
   fuse.last_response_message := null;
   fuse.response := null;
   fuse.g_session := null;
   fuse.g_image_session := null;
   fuse.g_model := null;
   fuse.g_image_model := null;
   fuse.g_provider := null;
   fuse.g_image_provider := null;
   fuse.g_provider_api_key := null;
   fuse.g_image_provider_api_key := null;
   fuse.randomness := null;
end;

procedure post_api_request (
   p_request_id in varchar2,
   p_api_url in varchar2,
   p_data in clob) is 
   v_header_name varchar2(4000);
   v_header_val varchar2(4000);
begin
   debug('post_api_request: '||p_data);
   apex_web_service.g_request_headers.delete();
   apex_web_service.g_request_headers(1).name := 'x-api-key';
   apex_web_service.g_request_headers(1).value := fuse.g_provider_api_key; 
   apex_web_service.g_request_headers(2).name := 'Authorization';
   apex_web_service.g_request_headers(2).value := 'Bearer '||fuse.g_provider_api_key; 
   apex_web_service.g_request_headers(3).name := 'anthropic-version';
   apex_web_service.g_request_headers(3).value := '2023-06-01'; 
   apex_web_service.g_request_headers(4).name := 'Content-Type';
   apex_web_service.g_request_headers(4).value := 'application/json'; 
   -- The entire response is stored in response global var. Use with caution of course.
   app_api.response := apex_web_service.make_rest_request (
      p_url         => p_api_url, 
      p_http_method => 'POST',
      p_body        => p_data);

   -- Do not try to debug log the response. It can be large and will exceed limit of varchar2 and raise error.
   -- Instead we will write the raw response to a table.
   log_response(app_api.response);

   -- Log headers if verbose=true
   if app_api.verbose then
      for i in 1.. apex_web_service.g_headers.count loop
         v_header_name := apex_web_service.g_headers(i).name;
         v_header_val := apex_web_service.g_headers(i).value;
         dbms_output.put_line(v_header_name||': '||v_header_val);
         debug(v_header_name||': '||v_header_val);
      end loop;
   end if;

   app_api.last_status_code := apex_web_service.g_status_code;
   debug('g_reason_phrase: '||apex_web_service.g_reason_phrase);
   debug('last_status_code: '||app_api.last_status_code);

   -- The response is parsed into individual rows in the json_data table.
   app_json.json_to_data_table (
      p_json_data=>app_api.response,
      p_json_key=>p_request_id);

   app_json.assert_no_errors (
      p_json_key=>p_request_id,
      p_error_path=>'root.error',
      p_error_type_path=>'root.error.type',
      p_error_message_path=>'root.error.message');

exception
   when others then
      raise_application_error(-20000, 'post_api_request: '||sqlerrm);
end;

function get_provider (
   p_provider_id in number) return fuse_provider%rowtype is
   v_provider fuse_provider%rowtype;
begin
   select * into v_provider from fuse_provider where provider_id = p_provider_id;
   return v_provider;
exception
   when no_data_found then
      raise_application_error(-20000, 'Provider not found: '||p_provider_id);
end;

function get_model (
   p_model_name in varchar2) return provider_model%rowtype is
   v_model provider_model%rowtype;
begin
   debug('get_model: '||p_model_name);
   select * into v_model from provider_model where model_name = p_model_name;
   return v_model;
exception
   when no_data_found then
      raise_application_error(-20000, 'Model not found: '||p_model_name);
end;

function get_model (
   p_model_id in number) return provider_model%rowtype is
   v_model provider_model%rowtype;
begin
   debug('get_model: '||p_model_id);
   select * into v_model from provider_model where model_id = p_model_id;
   return v_model;
exception
   when no_data_found then
      raise_application_error(-20000, 'Model not found: '||p_model_id);
end;

function get_session (
   p_session_name in varchar2) return fuse_session%rowtype is
   v_session fuse_session%rowtype;
begin
   debug('get_session: '||p_session_name);
   select * into v_session from fuse_session where session_name = p_session_name and status='active';
   return v_session;
exception
   when no_data_found then
      raise_application_error(-20000, 'Session not found: '||p_session_name);
end;

function get_session (
   p_session_id in number) return fuse_session%rowtype is
   v_session fuse_session%rowtype;
begin
   select * into v_session from fuse_session where session_id = p_session_id;
   return v_session;
exception
   when no_data_found then
      raise_application_error(-20000, 'Session not found: '||p_session_id);
end;

function get_session_prompt (
   p_session_prompt_id in number) return session_prompt%rowtype is
   v session_prompt%rowtype;
begin
   select * into v from session_prompt where session_prompt_id = p_session_prompt_id;
   return v;
exception
   when no_data_found then
      raise_application_error(-20000, 'Session prompt not found: '||p_session_prompt_id);
end;

procedure api_request (
   p_session_prompt_id in varchar2) is
   p session_prompt%rowtype;
   data_json clob;
   cursor prompts (p_session_id number) is
      select * from session_prompt
       where session_id=p_session_id and exclude=0
       order by session_id;
begin 
   debug('api_request: '||p_session_prompt_id);
   p := get_session_prompt(p_session_prompt_id);
   apex_json.initialize_clob_output;
   apex_json.open_object;
   apex_json.write('model', fuse.g_model.model_name);
   apex_json.write('max_tokens', p.max_tokens);
   apex_json.write('temperature', p.randomness);
   -- apex_json.write('n', 1);
   if p.tools is not null then 
      apex_json.write('tools', p.tools);
      apex_json.write('name', p.function_name);
      apex_json.write('tool_choice', 'auto');
   end if;
   apex_json.open_array('messages');
   for prompt in prompts(fuse.g_session.session_id) loop 
      apex_json.open_object;
      if prompt.prompt_role = 'mock' then 
         apex_json.write('role', 'user');
      else 
         apex_json.write('role', prompt.prompt_role);
      end if;
      apex_json.write('content', prompt.prompt);
      if prompt.prompt_role = 'tool' then
         apex_json.write('name', prompt.function_name);
      end if;
      apex_json.close_object;
   end loop;
   apex_json.close_array;
   apex_json.close_object;
   data_json := apex_json.get_clob_output;
   -- if fuse.g_schema is not null and fuse.g_model.json_mode = 'Y' then 
   --    data_json := rtrim(trim(regexp_replace(data_json, chr(10), '')), '}') || ', "response_format": {"type": "json_object", "schema": '||fuse.g_schema||'}}';
   -- end if;
   post_api_request (
      p_request_id=>'fuse_api_request_'||p_session_prompt_id,
      p_api_url=>fuse.g_model.api_url,
      p_data=>data_json);
exception
   when others then
      raise_application_error(-20000, 'api_request: '||sqlerrm);
end;

function get_last_system_prompt (
   p_session_id in number) return varchar2 is
   v_prompt varchar2(4000);
begin
   select prompt into v_prompt from session_prompt
    where session_id=p_session_id and prompt_role='system';
   return v_prompt;
exception
   when no_data_found then
      return null;
end;

procedure anthropic_api_request (
   p_session_prompt_id in varchar2) is
   p session_prompt%rowtype;
   data_json clob;
   cursor prompts (p_session_id number) is
      select * from session_prompt
       where session_id=p_session_id and exclude=0
         and prompt_role != 'system'
       order by session_id;
   v_system_prompt varchar2(4000);
begin 
   debug('anthropic_api_request: '||p_session_prompt_id);
   p := get_session_prompt(p_session_prompt_id);
   apex_json.initialize_clob_output;
   apex_json.open_object;
   apex_json.write('model', fuse.g_model.model_name);
   apex_json.write('max_tokens', p.max_tokens);
   apex_json.write('temperature', p.randomness);
   if p.tools is not null then 
      apex_json.write('tools', p.tools);
      apex_json.write('name', p.function_name);
      apex_json.write('tool_choice', 'auto');
   end if;
   v_system_prompt := get_last_system_prompt(fuse.g_session.session_id);
   if v_system_prompt is not null then 
      apex_json.write('system', v_system_prompt);
   end if;
   apex_json.open_array('messages');
   for prompt in prompts(fuse.g_session.session_id) loop 
      apex_json.open_object;
      if prompt.prompt_role = 'mock' then 
         apex_json.write('role', 'user');
         apex_json.write('content', prompt.prompt);
      else 
         apex_json.write('role', prompt.prompt_role);
         apex_json.write('content', prompt.prompt);
      end if;
      if prompt.prompt_role = 'tool' then
         apex_json.write('name', prompt.function_name);
      end if;
      apex_json.close_object;
   end loop;
   apex_json.close_array;
   apex_json.close_object;
   data_json := apex_json.get_clob_output;
   -- if fuse.g_schema is not null and fuse.g_model.json_mode = 'Y' then 
   --    data_json := rtrim(trim(regexp_replace(data_json, chr(10), '')), '}') || ', "response_format": {"type": "json_object", "schema": '||fuse.g_schema||'}}';
   -- end if;
   post_api_request (
      p_request_id=>'fuse_api_request_'||p_session_prompt_id,
      p_api_url=>fuse.g_model.api_url,
      p_data=>data_json);
exception
   when others then
      raise_application_error(-20000, 'anthropic_api_request: '||sqlerrm);
end;

procedure assert_session_is_active (
   p_session_name in varchar2) is 
   n number;
begin
   select count(*) into n from fuse_session where session_name = p_session_name and status='active';
   if n = 0 then
      raise_application_error(-20000, 'Session not found/active: '||p_session_name);
   end if;
end;

procedure assert_image_session_is_active (
   p_session_name in varchar2) is 
   n number;
begin
   select count(*) into n from fuse_session where session_name = p_session_name and status='active';
   if n = 0 then
      raise_application_error(-20000, 'Session not found/active: '||p_session_name);
   end if;
end;

procedure set_session (
   p_session_name in varchar2) is 
begin
   debug('set_session: '||p_session_name);
   assert_session_is_active(p_session_name);
   select * into fuse.g_session from fuse_session where session_name = p_session_name and status='active';
   fuse.g_model := null;
   select * into fuse.g_model from provider_model where model_id=fuse.g_session.model_id;
   select * into fuse.g_provider from fuse_provider where provider_id=fuse.g_model.provider_id;
   if fuse.g_provider.provider_name = 'anthropic' then
      fuse.g_provider_api_key := fuse_config.anthropic_api_key;
   elsif fuse.g_provider.provider_name = 'openai' then
      fuse.g_provider_api_key := fuse_config.openai_api_key;
   elsif fuse.g_provider.provider_name = 'together' then
      fuse.g_provider_api_key := fuse_config.together_api_key;
   else
      raise_application_error(-20000, 'set_session: Provider key not found - '||fuse.g_provider.provider_name);
   end if;
end;

procedure set_image_session (
   p_session_name in varchar2) is 
begin
   debug('set_image_session: '||p_session_name);
   assert_image_session_is_active(p_session_name);
   select * into fuse.g_image_session from fuse_session where session_name = p_session_name and status='active';
   fuse.g_image_model := null;
   select * into fuse.g_image_model from provider_model where model_id=fuse.g_image_session.model_id;
   select * into fuse.g_image_provider from fuse_provider where provider_id=fuse.g_image_model.provider_id;
   if fuse.g_provider.provider_name = 'anthropic' then
      fuse.g_provider_api_key := fuse_config.anthropic_api_key;
   elsif fuse.g_provider.provider_name = 'openai' then
      fuse.g_provider_api_key := fuse_config.openai_api_key;
   elsif fuse.g_provider.provider_name = 'together' then
      fuse.g_provider_api_key := fuse_config.together_api_key;
   else
      raise_application_error(-20000, 'set_session: Provider key not found - '||fuse.g_provider.provider_name);
   end if;
end;

procedure create_session (
   p_session_name in varchar2,
   p_model_name in varchar2,
   p_pause in number default null,
   p_steps in number default null,
   p_images in number default null) is 
   v_pause fuse_session.pause%type := 0;
   v_session_name fuse_session.session_name%type := nvl(p_session_name, str_random(20));
   m provider_model%rowtype;
begin
   -- select p_session_name||'_'||sys_context('userenv', 'sessionid') info v_session_name from dual;
   debug('create_session: '||p_session_name);
   update fuse_session set status = 'inactive' where status = 'active' and session_name = v_session_name;
   m := get_model(p_model_name);
   insert into fuse_session (session_name, model_id, pause, status) 
      values (v_session_name, m.model_id, v_pause, 'active');
      debug('Insert new chat session: '||v_session_name);
   if m.model_type = 'image' then 
      set_image_session(v_session_name);
   else 
      set_session(v_session_name);
   end if;
end;

procedure assert_not_image_model is 
begin
   if fuse.g_model.model_type = 'image' then
      raise_application_error(-20000, 'Image model not supported.');
   end if;
end;

procedure assert_is_image_model is 
begin
   if fuse.g_image_model.model_type != 'image' then
      raise_application_error(-20000, 'Image model required.');
   end if;
end;

procedure image (
   p_prompt in varchar2,
   p_session_name in varchar2 default fuse.g_image_session.session_name,
   p_steps in number default 20,
   p_images in number default 1,
   p_width in number default 1024,
   p_height in number default 1024,
   p_seed in number default round(dbms_random.value(1,100)),
   p_negative_prompt in varchar2 default null) is
   data_json clob;
   cursor images (p_json_key in varchar2) is 
      select * from json_data where json_key=p_json_key and data_key='image_base64' order by json_data_id;
   v_image_index number := 0;
   v_json_key json_data.json_key%type := 'fuse_image_request_'||p_session_name;
begin
   debug('image: '||p_prompt);
   set_image_session(p_session_name);
   assert_is_image_model;
   if fuse.g_image_session.pause > 0 then
      dbms_lock.sleep(fuse.g_image_session.pause);
   end if; 
   apex_json.initialize_clob_output;
   apex_json.open_object;
   apex_json.write('model', fuse.g_image_model.model_name);
   apex_json.write('prompt', p_prompt);
   apex_json.write('n', p_images);
   apex_json.write('steps', p_steps);
   apex_json.write('width', p_width);
   apex_json.write('height', p_height);
   apex_json.write('seed', p_seed);
   if p_negative_prompt is not null then 
      apex_json.write('negative_prompt', p_negative_prompt);
   end if;
   apex_json.close_object;
   data_json := apex_json.get_clob_output;
   post_api_request (
      p_request_id=>v_json_key,
      p_api_url=>fuse.g_image_model.api_url,
      p_data=>data_json);

   for i in images(v_json_key) loop 
      v_image_index := v_image_index + 1;
      insert into session_image (
         session_id, 
         prompt,
         steps,
         seed,
         image_id,
         image_data) 
         values (
         fuse.g_image_session.session_id, 
         p_prompt,
         p_steps,
         p_seed,
         v_image_index,
         -- Credit: Tim Hall, https://oracle-base.com/dba/script?category=miscellaneous&file=base64decode.sql
         base64decode(i.data_value));
   end loop;

   -- ToDo: Add session accounting and cost calculation. Not sure how to do the latter.

end;

procedure system (
   p_prompt in varchar2,
   p_session_name in varchar2 default fuse.g_session.session_name,
   p_exclude in number default 0) is
begin
   debug('system: '||p_prompt);
   set_session(p_session_name);
   assert_not_image_model;
   insert into session_prompt (session_id, prompt_role, prompt, exclude, end_time) 
      values (fuse.g_session.session_id, 'system', p_prompt, p_exclude, systimestamp);
   dbms_output.put_line('system: '||p_prompt);
end;

procedure assistant (
   p_prompt in varchar2,
   p_session_name in varchar2 default fuse.g_session.session_name,
   p_exclude in number default 0) is
begin
   debug('assistant: '||p_prompt);
   set_session(p_session_name);
   assert_not_image_model;
   insert into session_prompt (session_id, prompt_role, prompt, exclude, end_time) 
      values (fuse.g_session.session_id, 'assistant', p_prompt, p_exclude, systimestamp);
   dbms_output.put_line('assistant: '||p_prompt);
end;

procedure mock (
   p_prompt in varchar2,
   p_session_name in varchar2 default fuse.g_session.session_name,
   p_exclude in number default 0) is
begin
   set_session(p_session_name);
   assert_not_image_model;
   insert into session_prompt (session_id, prompt_role, prompt, exclude, end_time) 
      values (fuse.g_session.session_id, 'mock', p_prompt, p_exclude, systimestamp);
   dbms_output.put_line('mock: '||p_prompt);
end;

procedure user (
   p_prompt in varchar2,
   p_session_name in varchar2 default fuse.g_session.session_name,
   p_response_id in varchar2 default null,
   p_schema in clob default null,
   p_exclude in number default 0,
   p_tools in clob default null,
   p_randomness in number default null,
   p_max_tokens in number default null) is
   v session_prompt%rowtype;
   v_randomness number := p_randomness;
begin
   debug('user: ');
   dbms_output.put_line('user: '||p_prompt);
   set_session(p_session_name);
   assert_not_image_model;

   if v_randomness is null then 
      v_randomness := nvl(fuse.randomness, 1);
   end  if;

   if fuse.g_session.pause > 0 then
      dbms_lock.sleep(fuse.g_session.pause);
   end if;

   insert into session_prompt (
      session_id, 
      prompt_role, 
      prompt, 
      schema,
      randomness,
      max_tokens,
      tools,
      response_id,
      exclude) 
      values (
      fuse.g_session.session_id, 
      'user', 
      p_prompt, 
      p_schema,
      v_randomness,
      nvl(p_max_tokens, nvl(fuse.max_tokens, 1)),
      p_tools,
      p_response_id,
      p_exclude) returning session_prompt_id into v.session_prompt_id;

   commit;

   if fuse.g_provider.provider_name = 'anthropic' then
      anthropic_api_request(p_session_prompt_id=>v.session_prompt_id);
   else
      api_request(p_session_prompt_id=>v.session_prompt_id);
   end if;

   commit;

   -- Together
   if fuse.g_provider.provider_name in ('together', 'openai') then
      select trim(data_value) into fuse.response from json_data 
       where json_key = 'fuse_api_request_'||v.session_prompt_id and json_path = 'root.choices.1.message.content';
      select to_number(data_value) into v.total_tokens from json_data 
       where json_key = 'fuse_api_request_'||v.session_prompt_id and json_path = 'root.usage.total_tokens';
      select data_value into v.finish_reason from json_data 
       where json_key = 'fuse_api_request_'||v.session_prompt_id and json_path = 'root.choices.1.finish_reason';
   else 
      -- Anthropic
      select trim(data_value) into fuse.response from json_data 
       where json_key = 'fuse_api_request_'||v.session_prompt_id and json_path = 'root.content.1.text';
      select sum(to_number(data_value)) into v.total_tokens from json_data 
       where json_key = 'fuse_api_request_'||v.session_prompt_id and json_path in ('root.usage.input_tokens', 'root.usage.output_tokens');
      select data_value into v.finish_reason from json_data 
       where json_key = 'fuse_api_request_'||v.session_prompt_id and json_path = 'root.stop_reason';
   end if;

   update session_prompt 
      set total_tokens = v.total_tokens,
          finish_reason = v.finish_reason,
          end_time = systimestamp,
          elapsed_seconds = secs_between_timestamps(start_time, systimestamp)
    where session_prompt_id = v.session_prompt_id;

   update fuse_session 
      set total_tokens = total_tokens + v.total_tokens,
          elapsed_seconds = (select sum(elapsed_seconds) from session_prompt where session_id = fuse.g_session.session_id),
          call_count = call_count + 1
    where session_id = fuse.g_session.session_id;

   assistant(p_prompt=>fuse.response, p_session_name=>p_session_name, p_exclude=>p_exclude);

end;

procedure tool (
   p_prompt in varchar2,
   p_function_name in varchar2,
   p_session_name in varchar2 default fuse.g_session.session_name,
   p_response_id in varchar2 default null,
   p_exclude in number default 0) is
   v session_prompt%rowtype;
begin
   debug('tool: ');
   dbms_output.put_line('tool: '||p_prompt);
   set_session(p_session_name);
   assert_not_image_model;

   if fuse.g_session.pause > 0 then
      dbms_lock.sleep(fuse.g_session.pause);
   end if;

   insert into session_prompt (
      session_id, 
      prompt_role, 
      prompt, 
      function_name,
      response_id,
      exclude) 
      values (
      fuse.g_session.session_id, 
      'tool', 
      p_prompt, 
      p_function_name,
      p_response_id,
      p_exclude) returning session_prompt_id into v.session_prompt_id;

   commit;

   api_request (p_session_prompt_id=>v.session_prompt_id);

   commit;

   select trim(data_value) into fuse.response from json_data 
    where json_key = 'fuse_api_request_'||v.session_prompt_id and json_path = 'root.choices.1.message.content';

   select to_number(data_value) into v.total_tokens from json_data 
    where json_key = 'fuse_api_request_'||v.session_prompt_id and json_path = 'root.usage.total_tokens';

   select data_value into v.finish_reason from json_data 
    where json_key = 'fuse_api_request_'||v.session_prompt_id and json_path = 'root.choices.1.finish_reason';

   update session_prompt 
      set total_tokens = v.total_tokens,
          finish_reason = v.finish_reason,
          end_time = systimestamp,
          elapsed_seconds = secs_between_timestamps(start_time, systimestamp)
    where session_prompt_id = v.session_prompt_id;

   update fuse_session 
      set total_tokens = total_tokens + v.total_tokens,
          elapsed_seconds = (select sum(elapsed_seconds) from session_prompt where session_id = fuse.g_session.session_id),
          call_count = call_count + 1
    where session_id = fuse.g_session.session_id;

   assistant(p_prompt=>fuse.response, p_session_name=>p_session_name, p_exclude=>p_exclude);

end;

-- procedure replay (
--    p_session_name in varchar2 default null) is
--    v_session_id number;
--    cursor prompts (p_session_id in number) is
--    select * from session_prompt 
--     where session_id = p_session_id
--     order by session_prompt_id;
--    v_replay_session_id fuse_session.session_id%type;
-- begin
--    select max(session_id) into v_replay_session_id from fuse_session where session_name = p_session_name;
--    create_session(p_session_name);
--    for p in prompts(v_replay_session_id) loop
--       if p.prompt_role = 'system' then
--          system(p.prompt);
--       elsif p.prompt_role = 'user' then
--          user(p.prompt, p.response_id);
--       elsif p.prompt_role in ('assistant', 'tool') then
--          -- Do nothing
--          null;
--       end if;
--    end loop;
-- end;

function get_response (
   p_response_id in varchar2) return varchar2 is
   r session_prompt.prompt%type;
begin
   select prompt into r from session_prompt where response_id = p_response_id;
   return r;
end;

end;
/
