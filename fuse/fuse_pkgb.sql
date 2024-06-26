create or replace package body fuse as

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
   fuse.g_session_prompt := null;
   fuse.g_tool := null;
   fuse.tool_response := null;
end;

function make_rest_request (
   p_api_url in varchar2,
   p_api_key in varchar2,
   p_data in clob) return clob is 
   v_header_name varchar2(4000);
   v_header_val varchar2(4000);
   r clob;
begin
   debug('make_rest_request: '||p_data);
   if fuse.g_session.pause > 0 then
      dbms_lock.sleep(fuse.g_session.pause);
   end if;
   apex_web_service.g_request_headers.delete();
   apex_web_service.g_request_headers(1).name := 'Authorization';
   apex_web_service.g_request_headers(1).value := 'Bearer '||p_api_key;
   apex_web_service.g_request_headers(2).name := 'Content-Type';
   apex_web_service.g_request_headers(2).value := 'application/json'; 

   r := apex_web_service.make_rest_request(
      p_url         => p_api_url, 
      p_http_method => 'POST',
      p_body        => p_data);

   -- Log headers if verbose=true
   if fuse.verbose then
      for i in 1.. apex_web_service.g_headers.count loop
         v_header_name := apex_web_service.g_headers(i).name;
         v_header_val := apex_web_service.g_headers(i).value;
         dbms_output.put_line(v_header_name||': '||v_header_val);
         debug(v_header_name||': '||v_header_val);
      end loop;
   end if;

   fuse.last_status_code := apex_web_service.g_status_code;
   debug('g_reason_phrase: '||apex_web_service.g_reason_phrase);
   debug('last_status_code: '||fuse.last_status_code);
   return r;
exception
   when others then
      raise_application_error(-20000, 'make_rest_request: '||dbms_utility.format_error_stack);
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

function does_session_exist (
   p_session_id in number) return boolean is 
   n number;
begin
   select count(*) into n from fuse_session where session_id = p_session_id;
   return n > 0;
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

procedure set_session_prompt(
   p_session_prompt_id in number) is
begin
   select * into fuse.g_session_prompt from session_prompt where session_prompt_id = p_session_prompt_id;
end;

procedure set_tool (
   p_function_name in varchar2) is 
begin
   debug('set_tool: '||p_function_name);
   select * into fuse.g_tool from fuse_tool where function_name = p_function_name;
end;

procedure build_tool_group_json (
   p_tool_group_id in number) is
   v_json_key json_data.json_key%type;
   v_args varchar2(512);
   cursor tools (p_tool_group_id varchar2) is 
      select * from fuse_tool where tool_group_id=p_tool_group_id;
begin
   apex_json.write('tool_choice', 'auto');
   apex_json.open_array('tools');
   for t in tools(p_tool_group_id) loop 
      apex_json.open_object;
      apex_json.write('type', 'function');
         apex_json.open_object('function');
            apex_json.write('name', t.function_name);
            apex_json.write('description', t.function_desc);
            apex_json.open_object('parameters');
               if t.arg1 is not null then 
                  apex_json.write('type', 'object');
                  apex_json.open_object('properties');
                     apex_json.open_object(t.arg1);
                        apex_json.write('type', t.arg1_type);
                        apex_json.write('description', t.arg1_desc);
                     apex_json.close_object;
                  apex_json.close_object;
               end if;
               apex_json.open_array('required');
               apex_json.close_array;
            apex_json.close_object;
         apex_json.close_object;
      apex_json.close_object;
   end loop;
   apex_json.close_array;
end;

function get_json_data (
   p_session_prompt in out session_prompt%rowtype) return clob is
   p session_prompt%rowtype := p_session_prompt;
   cursor prompts (p_session_id number) is
      select * from session_prompt
       where session_id=p_session_id 
         and exclude=0
         and prompt is not null
       order by session_prompt_id;
   v_json_key json_data.json_key%type;
begin 
   debug('get_json_data: '||p.session_prompt_id);
   apex_json.initialize_clob_output;
   apex_json.open_object;
   apex_json.write('model', fuse.g_model.model_name);
   apex_json.write('max_tokens', fuse.g_session.max_tokens);
   apex_json.write('temperature', fuse.g_session.randomness);
   if fuse.g_session.tool_group_id is not null and p.prompt_role in ('user', 'mock', 'assistant') then 
      build_tool_group_json(fuse.g_session.tool_group_id);
   end if;
   apex_json.open_array('messages');
   for prompt in prompts(fuse.g_session.session_id) loop 
      debug('prompt: '||prompt.prompt_role||': '||prompt.prompt);
      apex_json.open_object;
      apex_json.write('role', prompt.prompt_role);
      apex_json.write('content', prompt.prompt);
      if prompt.prompt_role in ('tool') then 
         apex_json.write('tool_call_id', prompt.tool_call_id);
         apex_json.write('name', prompt.function_name);
      end if;
      apex_json.close_object;
   end loop;
   apex_json.close_array;
   apex_json.close_object;
   return apex_json.get_clob_output;
exception
   when others then
      raise_application_error(-20000, 'get_json_data: '||dbms_utility.format_error_stack);
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

procedure set_session_model_provider (
   p_session_name in varchar2) is 
begin
   debug('set_session_model_provider: '||p_session_name);
   assert_session_is_active(p_session_name);
   select * into fuse.g_session from fuse_session where session_name = p_session_name and status='active';
   select * into fuse.g_model from provider_model where model_id=fuse.g_session.model_id;
   select * into fuse.g_provider from fuse_provider where provider_id=fuse.g_model.provider_id;
   fuse.g_model.api_key := 
      case fuse.g_provider.provider_name
         when 'openai' then fuse_config.openai_api_key
         when 'together' then fuse_config.together_api_key
         when 'groq' then fuse_config.groq_api_key
      end;
   if fuse.g_model.api_key is null then 
      raise_application_error(-20000, 'API key not found for model: '||fuse.g_model.model_name);
   end if;
end;

procedure set_session_model_provider (
   p_session_id in number) is 
   v_session_name fuse_session.session_name%type;
begin
   debug('set_session_model_provider: '||p_session_id);
   select session_name into v_session_name from fuse_session where session_id=p_session_id;
   set_session_model_provider(p_session_name=>v_session_name);
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
   fuse.g_image_model.api_key := 
      case fuse.g_image_provider.provider_name
         when 'openai' then fuse_config.openai_api_key
         when 'together' then fuse_config.together_api_key
         when 'groq' then fuse_config.groq_api_key
      end;
   if fuse.g_image_model.api_key is null then 
      raise_application_error(-20000, 'API key not found for image model: '||fuse.g_image_model.model_name);
   end if;
end;

function get_tool_group_id (
   p_tool_group in varchar2) return number is
   n number;
begin
   select tool_group_id into n from tool_group where tool_group_name = p_tool_group;
   return n;
end;

procedure create_session (
   p_session_name in varchar2,
   p_model_name in varchar2,
   p_user_name in varchar2 default null,
   p_title in varchar2 default null,
   p_pause in number default 0,
   p_tool_group in varchar2 default null,
   p_steps in number default null,
   p_images in number default null) is 
   v_pause fuse_session.pause%type := 0;
   v_session_name fuse_session.session_name%type := nvl(p_session_name||'-'||p_user_name, str_random(20));
   m provider_model%rowtype;
   v_tool_group_id tool_group.tool_group_id%type;
begin
   -- select p_session_name||'_'||sys_context('userenv', 'sessionid') info v_session_name from dual;
   debug('create_session: '||p_session_name);
   if p_tool_group is not null then 
      v_tool_group_id := get_tool_group_id(p_tool_group);
   end if;
   m := get_model(p_model_name);
   update fuse_session set status = 'inactive' where status = 'active' and session_name = v_session_name;
   insert into fuse_session (
      session_name, 
      model_id, 
      user_name, 
      pause, 
      status,
      tool_group_id,
      session_title) values (
      v_session_name, 
      m.model_id, 
      p_user_name, 
      v_pause, 
      'active',
      v_tool_group_id,
      p_title);
   debug('Insert new chat session: '||v_session_name);
   if m.model_type = 'image' then 
      set_image_session(v_session_name);
   else 
      set_session_model_provider(v_session_name);
   end if;
end;

procedure request_session (
   p_session_name in varchar2,
   p_model_name in varchar2,
   p_user_name in varchar2 default null,
   p_pause in number default 0,
   p_steps in number default null,
   p_images in number default null) is
   -- This proc is called when the user wants to create a new session or continue an existing session.
   n number;
begin
   select count(*) into n from fuse_session 
    where session_name = p_session_name||'-'||p_user_name
      and status='active'
      and model_id = (select model_id from provider_model where model_name = p_model_name)
      and nvl(user_name, 'null') = nvl(p_user_name, 'null');
   if n = 1 then 
      set_session_model_provider(p_session_name||'-'||p_user_name);
   else
      create_session(
         p_session_name=>p_session_name, 
         p_model_name=>p_model_name,
         p_user_name=>p_user_name, 
         p_pause=>p_pause, 
         p_steps=>p_steps, 
         p_images=>p_images);
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

-- procedure image (
--    p_prompt in varchar2,
--    p_session_name in varchar2 default fuse.g_image_session.session_name,
--    p_steps in number default 20,
--    p_images in number default 1,
--    p_width in number default 1024,
--    p_height in number default 1024,
--    p_seed in number default round(dbms_random.value(1,100)),
--    p_negative_prompt in varchar2 default null) is
--    data_json clob;
--    cursor images (p_json_key in varchar2) is 
--       select * from json_data where json_key=p_json_key and data_key='image_base64' order by json_data_id;
--    v_image_index number := 0;
--    v_json_key json_data.json_key%type := 'fuse_image_request_'||p_session_name;
-- begin
--    debug('image: '||p_prompt);
--    set_image_session(p_session_name);
--    assert_is_image_model;
--    if fuse.g_image_session.pause > 0 then
--       dbms_lock.sleep(fuse.g_image_session.pause);
--    end if; 
--    apex_json.initialize_clob_output;
--    apex_json.open_object;
--    apex_json.write('model', fuse.g_image_model.model_name);
--    apex_json.write('prompt', p_prompt);
--    apex_json.write('n', p_images);
--    apex_json.write('steps', p_steps);
--    apex_json.write('width', p_width);
--    apex_json.write('height', p_height);
--    apex_json.write('seed', p_seed);
--    if p_negative_prompt is not null then 
--       apex_json.write('negative_prompt', p_negative_prompt);
--    end if;
--    apex_json.close_object;
--    data_json := apex_json.get_clob_output;
--    make_rest_request(
--       p_request_id=>v_json_key,
--       p_session_prompt_id=>null,
--       p_api_url=>fuse.g_image_model.api_url,
--       p_api_key=>fuse.g_image_model.api_key,
--       p_data=>data_json);

--    for i in images(v_json_key) loop 
--       v_image_index := v_image_index + 1;
--       insert into session_image (
--          session_id, 
--          prompt,
--          steps,
--          seed,
--          image_id,
--          image_data) 
--          values (
--          fuse.g_image_session.session_id, 
--          p_prompt,
--          p_steps,
--          p_seed,
--          v_image_index,
--          -- Credit: Tim Hall, https://oracle-base.com/dba/script?category=miscellaneous&file=base64decode.sql
--          base64decode(i.data_value));
--    end loop;

--    -- ToDo: Add session accounting and cost calculation. Not sure how to do the latter.

-- end;

procedure input (
   p_prompt in varchar2 default null) is 
begin
   fuse.input_prompt := p_prompt;
end;

function input return varchar2 is 
begin
   return fuse.input_prompt;
end;

function assert_true (
   p_assertion in varchar2) return boolean is
   -- assert_true('2+2=4');
begin
   create_session(p_session_name=>'assert_true', p_model_name=>fuse_config.default_model_name);
   -- fuse.system('You are an expert AI. You can evaluate any statement as either true of false. You only return the word true or false.');
   fuse.user(p_prompt=>'Evaluate the truthfulness of the following: '||p_assertion);
   return instr(lower(fuse.response), 'true') > 0;
end;

procedure system (
   p_prompt in session_prompt.prompt%type,
   p_session_name in varchar2 default fuse.g_session.session_name) is
   v_prompt session_prompt.prompt%type := p_prompt;
begin
   debug('system: '||p_prompt);
   set_session_model_provider(p_session_name);
   assert_not_image_model;
   insert into session_prompt (session_prompt_id, session_id, prompt_role, prompt, end_time, finish_reason) 
      values (seq_session_prompt_id.nextval, fuse.g_session.session_id, 'system', v_prompt, systimestamp, 'success');
end;

procedure assistant (
   p_prompt in session_prompt.prompt%type,
   p_session_name in varchar2 default fuse.g_session.session_name) is
   v_prompt session_prompt.prompt%type := p_prompt;
begin
   debug('assistant: '||p_prompt);
   set_session_model_provider(p_session_name);
   assert_not_image_model;
   if lower(substr(v_prompt, 1, 10)) = 'assistant:' then 
      v_prompt := extract_text(substr(v_prompt, instr(v_prompt, ':')+1), '[', ']');
   end if;
   insert into session_prompt (session_prompt_id, session_id, prompt_role, prompt, end_time, finish_reason) 
      values (seq_session_prompt_id.nextval, fuse.g_session.session_id, 'assistant', v_prompt, systimestamp, 'success');
end;

procedure mock (
   p_prompt in varchar2,
   p_session_name in varchar2 default fuse.g_session.session_name) is
begin
   set_session_model_provider(p_session_name);
   assert_not_image_model;
   insert into session_prompt (session_prompt_id, session_id, prompt_role, prompt, end_time) 
      values (seq_session_prompt_id.nextval, fuse.g_session.session_id, 'mock', p_prompt, systimestamp);
   dbms_output.put_line('mock: '||p_prompt);
end;

function get_clob_message_object (
   p_role in varchar2,
   p_prompt in clob) return clob is 
begin 
   apex_json.initialize_clob_output;
   apex_json.open_object;
   apex_json.write('role', 'user');
   apex_json.write('content', p_prompt);
   apex_json.close_object;
   return apex_json.get_clob_output;
end;

function replace_template_parameters (
   p_session_id in number,
   p_prompt in session_prompt.prompt%type) return clob is 
   r clob := p_prompt;
   v_param_count number;
   v_param_name json_data.data_key%type;
   v_param_value json_data.data_value%type;
   i number;
   v_json_key json_data.json_key%type := 'session_template_'||p_session_id;
begin
   select count(*) into v_param_count from json_data where json_key=v_json_key and json_path = 'root.parameters';
   for i in 1 .. v_param_count loop
      v_param_name := app_json.get_json_data_string(p_json_key=>v_json_key, p_json_path=>'root.parameters.'||i||'.name');
      v_param_value := app_json.get_json_data_string(p_json_key=>v_json_key, p_json_path=>'root.parameters.'||i||'.value');
      r := replace(r, '##'||v_param_name||'##', v_param_value);
   end loop;
   return r;
end;

procedure handle_template (
   p_session_id in number) is
   v_json_key json_data.json_key%type := 'session_template_'||p_session_id;
   v_message_count number;
   v_role session_prompt.prompt_role%type;
   v_content session_prompt.prompt%type;
   i number;
begin
   debug('handle_template: '||p_session_id);

   -- If the template has a system message, process it.
   if app_json.does_json_data_path_exist(p_json_key=>v_json_key, p_json_path=>'root.system') then 
      fuse.system(
         replace_template_parameters(
            p_session_id, 
            app_json.get_json_data_string(p_json_key=>v_json_key, p_json_path=>'root.system')));
   end if;

   select count(*) into v_message_count from json_data where json_key=v_json_key and json_path = 'root.messages';

   for i in 1 .. v_message_count loop
      v_role := app_json.get_json_data_string(p_json_key=>v_json_key, p_json_path=>'root.messages.'||i||'.role');
      v_content := app_json.get_json_data_string(p_json_key=>v_json_key, p_json_path=>'root.messages.'||i||'.content');
      v_content := replace_template_parameters(p_session_id, v_content);
      if v_role = 'system' then 
         fuse.system(v_content);
      elsif v_role = 'assistant' then
         fuse.assistant(v_content);
      else
         fuse.user(v_content);
      end if;
   end loop;
   
exception
   when others then
      raise_application_error(-20000, 'handle_template: '||dbms_utility.format_error_stack);

end;

procedure chat (
   p_prompt in varchar2,
   p_session_name in varchar2 default fuse.g_session.session_name) is
begin
   debug('chat: '||p_prompt);
   set_session_model_provider(p_session_name);
   assert_not_image_model;
   if lower(substr(p_prompt, 1, 7)) = '/system' then
      system(trim(substr(p_prompt, 8)), p_session_name);
   elsif lower(substr(p_prompt, 1, 5)) = '/user' then
      user(p_prompt, p_session_name);
   elsif lower(substr(p_prompt, 1, 5)) = '/mock' then
      mock(trim(substr(p_prompt, 6)), p_session_name);
   elsif lower(substr(p_prompt, 1, 10)) = '/assistant' then
      assistant(p_prompt, p_session_name);
   elsif lower(substr(p_prompt, 1, 9)) = '/template' then
      -- The body of the post is a json template to process.
      app_json.json_to_data_table(
         p_json_data=>trim(substr(p_prompt, 10)),
         p_json_key=>'session_template_'||fuse.g_session.session_id);
      insert into session_prompt (session_prompt_id, session_id, prompt_role, prompt, end_time, exclude) 
      values (seq_session_prompt_id.nextval, fuse.g_session.session_id, 'template', trim(substr(p_prompt, 10)), systimestamp, 1);
      handle_template(fuse.g_session.session_id);
   else
      user(p_prompt, p_session_name);
   end if;
end;

procedure user (
   p_prompt in varchar2,
   p_session_name in varchar2 default fuse.g_session.session_name) is
   -- user prompt
   u session_prompt%rowtype;
   -- Every user prompt results in an assistent.
   a session_prompt%rowtype;
   -- A tool may need to be called.
   t session_prompt%rowtype;
   v_json_key json_data.json_key%type;
   v_args varchar2(512);
begin
   debug('user: '||p_prompt);
   set_session_model_provider(p_session_name);
   assert_not_image_model;

   -- user has submitted a prompt
   u.session_prompt_id := seq_session_prompt_id.nextval;
   u.created := systimestamp;
   u.exclude := 0;
   u.session_id := fuse.g_session.session_id;
   u.start_time := systimestamp;
   u.prompt_role := 'user';
   u.prompt := p_prompt;
   u.total_tokens := 0;
   u.end_time := systimestamp;
   u.elapsed_seconds := secs_between_timestamps(u.start_time, u.end_time);
   u.finish_reason := 'success';
   insert into session_prompt values u;
   u.json_data := get_json_data(u);
   update session_prompt set row = u where session_prompt_id = u.session_prompt_id;
   commit;

   -- assistant will respond
   a.session_prompt_id := seq_session_prompt_id.nextval;
   a.created := systimestamp;
   a.exclude := 0;
   v_json_key := 'fuse_assistant_'||a.session_prompt_id;
   a.session_id := fuse.g_session.session_id;
   a.start_time := systimestamp;
   a.prompt_role := 'assistant';
   insert into session_prompt values a;

   a.json_data := make_rest_request (
      p_api_url=>fuse.g_model.api_url,
      p_api_key=>fuse.g_model.api_key,
      p_data=>u.json_data);
   -- The response is parsed into individual rows in the json_data table.
   app_json.json_to_data_table (
      p_json_data=>a.json_data,
      p_json_key=>v_json_key);
   commit;
   app_json.assert_no_errors (
      p_json_key=>v_json_key,
      p_error_path=>'root.error',
      p_error_type_path=>'root.error.type',
      p_error_message_path=>'root.error.message');
   a.total_tokens := app_json.get_json_data_number(p_json_key=>v_json_key, p_json_path=>'root.usage.total_tokens');
   a.finish_reason := app_json.get_json_data_string(p_json_key=>v_json_key, p_json_path=>'root.choices.1.finish_reason');
   if a.finish_reason = 'tool_calls' then 
      a.function_name := app_json.get_json_data_string(p_json_key=>v_json_key, p_json_path=>'root.choices.1.message.tool_calls.1.function.name');
      a.tool_call_id := app_json.get_json_data_string(p_json_key=>v_json_key, p_json_path=>'root.choices.1.message.tool_calls.1.id');
      set_tool(a.function_name);
      if app_json.does_json_data_path_exist(p_json_key=>v_json_key, p_json_path=>'root.choices.1.message.tool_calls.1.function.arguments') then 
         v_args := app_json.get_json_data_string(p_json_key=>v_json_key, p_json_path=>'root.choices.1.message.tool_calls.1.function.arguments');
      end if;
      if fuse.g_tool.arg1 is not null then 
         a.arg1 := fuse.g_tool.arg1;
         a.val1 := json_value(v_args, '$.'||a.arg1);
      end if;
      if fuse.g_tool.arg2 is not null then 
         a.arg2 := fuse.g_tool.arg2;
         a.val2 := json_value(v_args, '$.'||a.arg2);
      end if;
   end if;
   a.end_time := systimestamp;
   a.elapsed_seconds := secs_between_timestamps(a.start_time, a.end_time);
   if a.finish_reason != 'tool_calls' then 
      a.prompt := trim(app_json.get_json_data_clob(p_json_key=>v_json_key, p_json_path=>'root.choices.1.message.content'));
   end if;
   update session_prompt set row = a where session_prompt_id = a.session_prompt_id;
   commit;

   -- assistant possibly came back with a tool call
   if a.finish_reason = 'tool_calls' then 
      t.session_prompt_id := seq_session_prompt_id.nextval;
      t.created := systimestamp;
      t.exclude := 0;
      t.session_id := fuse.g_session.session_id;
      t.start_time := systimestamp;
      t.prompt_role := 'tool';
      t.prompt := null;
      t.arg1 := a.arg1;
      t.arg2 := a.arg2;
      t.function_name := a.function_name;
      t.tool_call_id := a.tool_call_id;
      t.val1 := a.val1;
      t.val2 := a.val2;
      if a.arg1 is null and a.arg2 is null then 
         execute immediate 'begin '||a.function_name||'; end;';
      elsif a.arg1 is not null and t.arg2 is null then 
         execute immediate 'begin '||a.function_name||'(:x); end;' using a.val1;
      else
         execute immediate 'begin '||a.function_name||'(:x, :y); end;' using a.val1, a.val2;
      end if;
      t.prompt := fuse.tool_response;
      t.end_time := systimestamp;
      t.elapsed_seconds := secs_between_timestamps(t.start_time, t.end_time);
      t.total_tokens := 0;
      insert into session_prompt values t;
      t.json_data := get_json_data(t);
      t.finish_reason := 'success';
      update session_prompt set row = t where session_prompt_id = t.session_prompt_id;
      commit;

      -- Update the assistent with the results of the call
      a := null;
      a.session_prompt_id := seq_session_prompt_id.nextval;
      a.created := systimestamp;
      a.exclude := 0;
      v_json_key := 'fuse_assistant_'||a.session_prompt_id;
      a.session_id := fuse.g_session.session_id;
      a.start_time := systimestamp;
      a.prompt_role := 'assistant';
      insert into session_prompt values a;
      a.json_data := make_rest_request (
         p_api_url=>fuse.g_model.api_url,
         p_api_key=>fuse.g_model.api_key,
         p_data=>t.json_data);
      app_json.json_to_data_table (
         p_json_data=>a.json_data,
         p_json_key=>v_json_key);
      commit;
      app_json.assert_no_errors (
         p_json_key=>v_json_key,
         p_error_path=>'root.error',
         p_error_type_path=>'root.error.type',
         p_error_message_path=>'root.error.message');
      a.prompt := trim(app_json.get_json_data_clob(p_json_key=>v_json_key, p_json_path=>'root.choices.1.message.content'));
      a.total_tokens := app_json.get_json_data_number(p_json_key=>v_json_key, p_json_path=>'root.usage.total_tokens');
      a.finish_reason := app_json.get_json_data_string(p_json_key=>v_json_key, p_json_path=>'root.choices.1.finish_reason');
      a.end_time := systimestamp;
      a.elapsed_seconds := secs_between_timestamps(a.start_time, a.end_time);
      update session_prompt set row = a where session_prompt_id = a.session_prompt_id;
      commit;
   end if;
end;

procedure add_tool_group (
   p_tool_group in varchar2,
   p_desc in varchar2) is 
begin
   insert into tool_group (tool_group_name, description) values (p_tool_group, p_desc);
end;

procedure add_tool (
   p_tool_group in varchar2,
   p_function_name in varchar2,
   p_function_desc in varchar2,
   p_arg1 varchar2 default null,
   p_arg1_type varchar2 default null,
   p_arg1_desc varchar2 default null,
   p_arg1_req boolean default false,
   p_arg2 varchar2 default null,
   p_arg2_type varchar2 default null,
   p_arg2_desc varchar2 default null,
   p_arg2_req boolean default false) is 
   v_arg1_req number := 0;
   v_arg2_req number := 0;
   v_tool_group_id number;
begin
   if p_arg1_req then 
      v_arg1_req := 1;
   end if;
   if p_arg2_req then 
      v_arg2_req := 1;
   end if;

   select tool_group_id into v_tool_group_id 
     from tool_group 
    where tool_group_name = p_tool_group;

   insert into fuse_tool (
      tool_group_id, 
      function_name, 
      function_desc,
      arg1,
      arg1_type,
      arg1_desc,
      arg1_req,
      arg2,
      arg2_type,
      arg2_desc,
      arg2_req) 
      values (
      v_tool_group_id, 
      p_function_name, 
      p_function_desc,
      p_arg1,
      p_arg1_type,
      p_arg1_desc,
      v_arg1_req,
      p_arg2,
      p_arg2_type,
      p_arg2_desc,
      v_arg2_req);
exception
   when others then
      raise_application_error(-20000, 'add_tool: '||dbms_utility.format_error_stack);
end;

end;
/
