create or replace package body fuse as

procedure post_request_all (
   p_request_id in varchar2,
   p_url in varchar2,
   p_data in clob) is 
   v_header_name varchar2(4000);
   v_header_val varchar2(4000);
begin
   debug('post_request_all: '||p_data);
   -- The entire response is stored in response global var. Use with caution of course.
   app_api.response := apex_web_service.make_rest_request (
      p_url         => p_url, 
      p_http_method => 'POST',
      p_body        => p_data);

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
   debug('response: '||app_api.response);

   -- The response is parsed into individual rows in the json_data table.
   app_json.json_to_data_table (
      p_json_data=>app_api.response,
      p_json_key=>p_request_id);

   app_json.assert_no_errors (
      p_json_key=>p_request_id,
      p_error_path=>'root.error',
      p_error_type_path=>'root.error.type',
      p_error_message_path=>'root.error.message');

end;

procedure post_anthropic_request (
   p_request_id in varchar2,
   p_api_token in varchar2,
   p_url in varchar2,
   p_data in clob) is 
begin
   debug('post_anthropic_request: '||p_api_token);
   debug('post_anthropic_request: '||p_data);
   apex_web_service.g_request_headers.delete();
   apex_web_service.g_request_headers(1).name := 'x-api-key';
   apex_web_service.g_request_headers(1).value := p_api_token; 
   apex_web_service.g_request_headers(2).name := 'anthropic-version';
   apex_web_service.g_request_headers(2).value := '2023-06-01'; 
   apex_web_service.g_request_headers(3).name := 'Content-Type';
   apex_web_service.g_request_headers(3).value := 'application/json'; 
   post_request_all (
      p_request_id=>p_request_id,
      p_url=>p_url,
      p_data=>p_data);
end;

procedure post_together_request (
   p_request_id in varchar2,
   p_api_token in varchar2,
   p_url in varchar2,
   p_data in clob) is 
begin
   debug('post_request: '||p_api_token);
   apex_web_service.g_request_headers.delete();
   apex_web_service.g_request_headers(1).name := 'Authorization';
   apex_web_service.g_request_headers(1).value := 'Bearer '||p_api_token; 
   apex_web_service.g_request_headers(2).name := 'Content-Type';
   apex_web_service.g_request_headers(2).value := 'application/json'; 
   post_request_all (
      p_request_id=>p_request_id,
      p_url=>p_url,
      p_data=>p_data);
end;

function get_provider (
   p_provider_id in number) return ai_provider%rowtype is
   v_provider ai_provider%rowtype;
begin
   select * into v_provider from ai_provider where provider_id = p_provider_id;
   return v_provider;
exception
   when no_data_found then
      raise_application_error(-20000, 'Provider not found: '||p_provider_id);
end;

function get_model (
   p_model_name in varchar2) return ai_model%rowtype is
   v_model ai_model%rowtype;
begin
   debug('get_model: '||p_model_name);
   select * into v_model from ai_model where model_name = p_model_name;
   return v_model;
exception
   when no_data_found then
      raise_application_error(-20000, 'Model not found: '||p_model_name);
end;

function get_model (
   p_model_id in number) return ai_model%rowtype is
   v_model ai_model%rowtype;
begin
   debug('get_model: '||p_model_id);
   select * into v_model from ai_model where model_id = p_model_id;
   return v_model;
exception
   when no_data_found then
      raise_application_error(-20000, 'Model not found: '||p_model_id);
end;

function get_session (
   p_session_name in varchar2) return ai_session%rowtype is
   v_session ai_session%rowtype;
begin
   debug('get_session: '||p_session_name);
   select * into v_session from ai_session where session_name = nvl(p_session_name, fuse.g_session.session_name) and status='active';
   return v_session;
exception
   when no_data_found then
      raise_application_error(-20000, 'Session not found: '||p_session_name);
end;

function get_session (
   p_session_id in number) return ai_session%rowtype is
   v_session ai_session%rowtype;
begin
   select * into v_session from ai_session where session_id = p_session_id;
   return v_session;
exception
   when no_data_found then
      raise_application_error(-20000, 'Session not found: '||p_session_id);
end;

function get_ai_session_prompt (
   p_session_prompt_id in number) return ai_session_prompt%rowtype is
   v ai_session_prompt%rowtype;
begin
   select * into v from ai_session_prompt where session_prompt_id = p_session_prompt_id;
   return v;
exception
   when no_data_found then
      raise_application_error(-20000, 'Session prompt not found: '||p_session_prompt_id);
end;

-- function get_request_data (
--    p_session_prompt_id in number default null) return clob is
--    data_json clob;
--    cursor prompts (p_session_id number) is
--    select * from ai_session_prompt
--     where session_id=p_session_id
--       and exclude=0
--     order by session_id;
--    p ai_session_prompt%rowtype;
--    s ai_session%rowtype;
--    m ai_model%rowtype;
-- begin
--    debug('get_request_data: '||p_session_prompt_id);
--    p := get_ai_session_prompt(p_session_prompt_id);
--    s := get_session(p.session_id);
--    m := get_model(s.model_id);

--    -- s : = '{model: "'||model_name||'", max_tokens: '||p_max_tokens||', temperature: '||p_randomness||', n: 1';
--    -- if p_schema is not null then 
--    --    s := s||', response_format: {type: "json_object", schema: '||p_schema||'}';
--    -- end if;
--    -- s := s||', messages: [';
--    -- for m in messages loop 
--    --    s := s||'{role: "'||m.prompt_role||'", content: "'||m.prompt||'"},';
--    -- end loop;
--    -- s := rtrim(s, ',')||']}';
--    -- debug(s);

--    apex_json.initialize_clob_output;
--    apex_json.open_object;
--    apex_json.write('model', m.model_name);
--    apex_json.write('max_tokens', s.max_tokens);
--    apex_json.write('temperature', s.randomness);
--    apex_json.write('n', 1);
--    if p.tools is not null then 
--       apex_json.write('tools', p.tools);
--       apex_json.write('tool_choice', 'auto');
--    end if;
--    apex_json.open_array('messages');
--    for prompt in prompts(s.session_id) loop 
--       apex_json.open_object;
--       apex_json.write('role', prompt.prompt_role);
--       apex_json.write('content', prompt.prompt);
--       apex_json.close_object;
--    end loop;
--    apex_json.close_array;
--    apex_json.close_object;
--    data_json := apex_json.get_clob_output;
--    -- if fuse.g_schema is not null and m.json_mode = 'Y' then 
--    --    data_json := rtrim(trim(regexp_replace(data_json, chr(10), '')), '}') || ', "response_format": {"type": "json_object", "schema": '||fuse.g_schema||'}}';
--    -- end if;
--    debug2(data_json);
--    return data_json;
-- end;

procedure make_api_request (
   p_session_prompt_id in varchar2) is
   provider ai_provider%rowtype;
   p ai_session_prompt%rowtype;
   s ai_session%rowtype;
   m ai_model%rowtype;
   data_json clob;
   cursor prompts (p_session_id number) is
      select * from ai_session_prompt
       where session_id=p_session_id and exclude=0
       order by session_id;
begin 
   debug('make_api_request: '||p_session_prompt_id);

   p := get_ai_session_prompt(p_session_prompt_id);
   s := get_session(p.session_id);
   m := get_model(s.model_id);
   provider := get_provider(m.provider_id);

   apex_json.initialize_clob_output;
   apex_json.open_object;
   apex_json.write('model', m.model_name);
   apex_json.write('max_tokens', s.max_tokens);
   -- apex_json.write('temperature', s.randomness);
   -- apex_json.write('n', 1);
   if p.tools is not null then 
      apex_json.write('tools', p.tools);
      apex_json.write('name', p.function_name);
      apex_json.write('tool_choice', 'auto');
   end if;
   apex_json.open_array('messages');
   for prompt in prompts(s.session_id) loop 
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
   -- if fuse.g_schema is not null and m.json_mode = 'Y' then 
   --    data_json := rtrim(trim(regexp_replace(data_json, chr(10), '')), '}') || ', "response_format": {"type": "json_object", "schema": '||fuse.g_schema||'}}';
   -- end if;
   debug2(data_json);

   if provider.provider_name = 'together.ai' then
      post_together_request (
         p_request_id=>'fuse_make_api_request_'||p_session_prompt_id,
         p_api_token=>provider.provider_api_key,
         p_url=>provider.provider_url,
         p_data=>data_json);
   else 
      post_anthropic_request (
         p_request_id=>'fuse_make_api_request_'||p_session_prompt_id,
         p_api_token=>provider.provider_api_key,
         p_url=>provider.provider_url,
         p_data=>data_json);
   end if;
exception
   when others then
      raise_application_error(-20000, 'make_api_request: '||sqlerrm);
end;

procedure set_session (
   p_session_name in varchar2) is 
begin
   select * into fuse.g_session from ai_session where session_name = p_session_name and status='active';
   select * into fuse.g_model from ai_model where model_id=fuse.g_session.model_id;
   select * into fuse.g_provider from ai_provider where provider_id=fuse.g_model.provider_id;
end;

procedure create_session (
   p_session_name in varchar2,
   p_model_name in varchar2 default null,
   p_max_tokens in number default null,
   p_randomness in number default null,
   p_pause in number default null) is 
   v_model_name ai_model.model_name%type := nvl(p_model_name, fuse.g_default_model_name);
   v_max_tokens ai_session.max_tokens%type := 1024;
   v_randomness ai_session.randomness%type := 1;
   v_pause ai_session.pause%type := 0;
   v_session_name ai_session.session_name%type := p_session_name;
   v_model_id ai_model.model_id%type;
begin
   -- select p_session_name||'_'||sys_context('userenv', 'sessionid') info v_session_name from dual;
   debug('create_session: '||p_session_name);
   update ai_session set status = 'inactive' where status = 'active' and session_name = v_session_name;

   -- When the only parameter provided is the session_name...
   if p_model_name is null and p_max_tokens is null and p_randomness is null and p_pause is null then 
      -- We will borrow the attributes from the last ai_session created.
      set_session(v_session_name);
      v_model_name := fuse.g_model.model_name;
      v_max_tokens := fuse.g_session.max_tokens;
      v_randomness := fuse.g_session.randomness;
      v_pause := fuse.g_session.pause;
   end if;
   select model_id into v_model_id from ai_model where model_name = v_model_name;
   insert into ai_session (session_name, model_id, max_tokens, randomness, pause, status) 
      values (v_session_name, v_model_id, v_max_tokens, v_randomness, v_pause, 'active');
   set_session(v_session_name);
end;

procedure system (
   p_prompt in varchar2,
   p_session_name in varchar2 default fuse.g_session.session_name,
   p_exclude in number default 0) is
begin
   set_session(p_session_name);
   insert into ai_session_prompt (session_id, prompt_role, prompt, exclude, end_time) 
      values (fuse.g_session.session_id, 'system', p_prompt, p_exclude, systimestamp);
   dbms_output.put_line('system: '||p_prompt);
end;

procedure assistant (
   p_prompt in varchar2,
   p_session_name in varchar2 default fuse.g_session.session_name,
   p_exclude in number default 0) is
begin
   set_session(p_session_name);
   insert into ai_session_prompt (session_id, prompt_role, prompt, exclude, end_time) 
      values (fuse.g_session.session_id, 'assistant', p_prompt, p_exclude, systimestamp);
   dbms_output.put_line('assistant: '||p_prompt);
end;

procedure mock (
   p_prompt in varchar2,
   p_session_name in varchar2 default fuse.g_session.session_name,
   p_exclude in number default 0) is
begin
   set_session(p_session_name);
   insert into ai_session_prompt (session_id, prompt_role, prompt, exclude, end_time) 
      values (fuse.g_session.session_id, 'mock', p_prompt, p_exclude, systimestamp);
   dbms_output.put_line('mock: '||p_prompt);
end;

procedure user (
   p_prompt in varchar2,
   p_session_name in varchar2 default fuse.g_session.session_name,
   p_response_id in varchar2 default null,
   p_schema in clob default null,
   p_exclude in number default 0,
   p_tools in clob default null) is
   v ai_session_prompt%rowtype;
begin
   debug('user: ');
   dbms_output.put_line('user: '||p_prompt);
   set_session(p_session_name);

   if fuse.g_session.pause > 0 then
      dbms_lock.sleep(fuse.g_session.pause);
   end if;

   insert into ai_session_prompt (
      session_id, 
      prompt_role, 
      prompt, 
      schema,
      tools,
      response_id,
      exclude) 
      values (
      fuse.g_session.session_id, 
      'user', 
      p_prompt, 
      p_schema,
      p_tools,
      p_response_id,
      p_exclude) returning session_prompt_id into v.session_prompt_id;

   commit;

   make_api_request(p_session_prompt_id=>v.session_prompt_id);

   commit;

   -- Together
   if fuse.g_provider.provider_name = 'together.ai' then
      select trim(data_value) into fuse.response from json_data 
       where json_key = 'fuse_make_api_request_'||v.session_prompt_id and json_path = 'root.choices.1.message.content';
      select to_number(data_value) into v.total_tokens from json_data 
       where json_key = 'fuse_make_api_request_'||v.session_prompt_id and json_path = 'root.usage.total_tokens';
      select data_value into v.finish_reason from json_data 
       where json_key = 'fuse_make_api_request_'||v.session_prompt_id and json_path = 'root.choices.1.finish_reason';
   else 
      -- Anthropic
      select trim(data_value) into fuse.response from json_data 
       where json_key = 'fuse_make_api_request_'||v.session_prompt_id and json_path = 'root.content.1.text';
      select sum(to_number(data_value)) into v.total_tokens from json_data 
       where json_key = 'fuse_make_api_request_'||v.session_prompt_id and json_path in ('root.usage.input_tokens', 'root.usage.output_tokens');
      select data_value into v.finish_reason from json_data 
       where json_key = 'fuse_make_api_request_'||v.session_prompt_id and json_path = 'root.stop_reason';
   end if;

   update ai_session_prompt 
      set response = fuse.response,
          total_tokens = v.total_tokens,
          finish_reason = v.finish_reason,
          end_time = systimestamp,
          elapsed_seconds = secs_between_timestamps(start_time, systimestamp)
    where session_prompt_id = v.session_prompt_id;

   update ai_session 
      set total_tokens = total_tokens + v.total_tokens,
          elapsed_seconds = (select sum(elapsed_seconds) from ai_session_prompt where session_id = fuse.g_session.session_id),
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
   v ai_session_prompt%rowtype;
begin
   debug('tool: ');
   dbms_output.put_line('tool: '||p_prompt);
   set_session(p_session_name);

   if fuse.g_session.pause > 0 then
      dbms_lock.sleep(fuse.g_session.pause);
   end if;

   insert into ai_session_prompt (
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

   make_api_request (p_session_prompt_id=>v.session_prompt_id);

   commit;

   select trim(data_value) into fuse.response from json_data 
    where json_key = 'fuse_make_api_request_'||v.session_prompt_id and json_path = 'root.choices.1.message.content';

   select to_number(data_value) into v.total_tokens from json_data 
    where json_key = 'fuse_make_api_request_'||v.session_prompt_id and json_path = 'root.usage.total_tokens';

   select data_value into v.finish_reason from json_data 
    where json_key = 'fuse_make_api_request_'||v.session_prompt_id and json_path = 'root.choices.1.finish_reason';

   update ai_session_prompt 
      set response = fuse.response,
          total_tokens = v.total_tokens,
          finish_reason = v.finish_reason,
          end_time = systimestamp,
          elapsed_seconds = secs_between_timestamps(start_time, systimestamp)
    where session_prompt_id = v.session_prompt_id;

   update ai_session 
      set total_tokens = total_tokens + v.total_tokens,
          elapsed_seconds = (select sum(elapsed_seconds) from ai_session_prompt where session_id = fuse.g_session.session_id),
          call_count = call_count + 1
    where session_id = fuse.g_session.session_id;

   assistant(p_prompt=>fuse.response, p_session_name=>p_session_name, p_exclude=>p_exclude);

end;

procedure replay (
   p_session_name in varchar2 default null) is
   v_session_id number;
   cursor prompts (p_session_id in number) is
   select * from ai_session_prompt 
    where session_id = p_session_id
    order by session_prompt_id;
   v_replay_session_id ai_session.session_id%type;
begin
   select max(session_id) into v_replay_session_id from ai_session where session_name = p_session_name;
   create_session(p_session_name);
   for p in prompts(v_replay_session_id) loop
      if p.prompt_role = 'system' then
         system(p.prompt);
      elsif p.prompt_role = 'user' then
         user(p.prompt, p.response_id);
      elsif p.prompt_role in ('assistant', 'tool') then
         -- Do nothing
         null;
      end if;
   end loop;
end;

function get_response (
   p_response_id in varchar2) return varchar2 is
   r ai_session_prompt.response%type;
begin
   select response into r from ai_session_prompt where response_id = p_response_id;
   return r;
end;

end;
/
