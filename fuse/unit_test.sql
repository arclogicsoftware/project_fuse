


/*
Basic test that runs through selected model in the provider_model table and asks a basic question.
*/

declares
   -- Modify this to test specific models or all models.
   cursor models is select * from provider_model where model_name='gpt-3.5-turbo-0125';
   v_model_name provider_model.model_name%type;
begin
   for m in models loop 
      -- Make sure we wait at least one sec between calls due to rate limiters.
      dbms_lock.sleep(1);
      v_model_name := m.model_name;
      fuse.create_session (
         p_session_name=>m.model_name||'_test',
         p_model_name=>m.model_name,
         p_pause=>1);
      fuse.system('Answer all questions using a haiku.');
      fuse.user('What is the "true" meaning of the number '||round(dbms_random.value(1, 100))||'?');
   end loop;
exception 
   when others then 
      raise_application_error(-20000, '"true" meaning of number test: '||v_model_name||': '||sqlerrm);
end;
/

/*
Basic image model test.
*/
begin
   fuse.create_session(p_session_name=>'image_test',
      p_model_name=>'stabilityai/stable-diffusion-2-1');
   fuse.image(p_prompt=>'A cat in a hat.', p_steps=>20, p_images=>1);
end;
/





-- begin 
--    fuse.create_session (
--       p_session_name=>'first_test',
--       -- p_model_name=>'codellama/CodeLlama-34b-Instruct-hf');
--       p_model_name=>'claude-3-haiku-20240307');
--    -- Need to fix for Anthropic
--    -- ORA-20000: make_api_request: ORA-20001: Error: invalid_request_error messages: Unexpected role "system". The Messages API accepts a top-level `system` parameter, not "system" as an input message role.
--    -- ORA-06512: at "APP1.FUSE", line 274
--    fuse.system('You are a conservative Cambridge scholar, one of the last of a dying breed.');
--    fuse.user('If I could pick on random book from your extensive library that I should read, what is it, and why?"');
--    dbms_output.put_line('response: '||fuse.response);
--    commit;
--    if fuse.response is null then 
--       raise_application_error(-20000, 'Response is null.');
--    end if;
-- end;
-- /

delete from log_table;
delete from fuse_session;
delete from json_data;
 
select * from provider_model;
select * from log_table order by 1 desc;
select * from json_data order by 1 desc;
select * from session_prompt order by 1 desc;
delete from session_prompt;
