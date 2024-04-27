


begin 
   fuse.create_session (
      p_session_name=>'first_test',
      -- p_model_name=>'codellama/CodeLlama-34b-Instruct-hf');
      p_model_name=>'claude-3-haiku-20240307');
   -- Need to fix for Anthropic
   -- ORA-20000: make_api_request: ORA-20001: Error: invalid_request_error messages: Unexpected role "system". The Messages API accepts a top-level `system` parameter, not "system" as an input message role.
   -- ORA-06512: at "APP1.FUSE", line 274
   fuse.system('You are a conservative Cambridge scholar, one of the last of a dying breed.');
   fuse.user('If I could pick on random book from your extensive library that I should read, what is it, and why?"');
   dbms_output.put_line('response: '||fuse.response);
   commit;
   if fuse.response is null then 
      raise_application_error(-20000, 'Response is null.');
   end if;
end;
/

select * from ai_model;
delete from log_table;
delete from ai_session;
select * from log_table order by 1 desc;
delete from json_data;
select * from json_data order by 1 desc;
select * from ai_session_prompt order by 1 desc;
delete from ai_session_prompt;
