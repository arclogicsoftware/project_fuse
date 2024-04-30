


/*
Basic test that runs through selected model in the provider_model table and asks a basic question.
*/

declare
   -- Modify this to test specific models or all models.
   cursor models is select * from provider_model where model_name='gpt-3.5-turbo-0125' and model_type='chat';
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
- Tested: https://docs.together.ai/docs/examples#image-generation
*/

declare
   image_prompt clob;
begin
   fuse.create_session(
      p_session_name=>'image_prompt', 
      p_model_name=>'claude-3-haiku-20240307');
   fuse.user(p_prompt=>'Generate a short interesting prompt I can use to generate an image from.');
   image_prompt := fuse.response;
   fuse.create_session(
      p_session_name=>'image_test',
      p_model_name=>'stabilityai/stable-diffusion-2-1');
   fuse.image(
      p_prompt=>image_prompt, 
      p_steps=>round(dbms_random.value(10,30)), 
      p_images=>2, 
      p_seed=>round(dbms_random.value(1,100)));
end;
/


/*
Extract text and image example.
*/

-- Re-initializes some global variables in case anything is still hanging around.
exec fuse.init;
-- Create a session called 'image-agent' using Gemma.
exec fuse.create_session('image-agent', 'mistralai/Mixtral-8x7B-Instruct-v0.1');
-- Create a system prompt. We don't need to specifiy the session since we only have one.
exec fuse.system('You are a an ingenious art dealer and entrepreneur.');
-- Set randomness (temperature) for our upcoming prompts.
exec fuse.randomness := .3;
-- Create a user prompt.
exec fuse.user('Provide a short creative sentence I can use to generate an image. Enclose your answer within <> angle brackets');
-- Create an image session called 'image-engine'.
exec fuse.create_session('image-engine', 'stabilityai/stable-diffusion-2-1');
-- Extract the result of the last prompt and create an image from it.
exec fuse.image(p_prompt=>extract_text(fuse.response, '<', '>'), p_steps=>40);
-- Run another user prompt. We do not need to specify the session name. Although we have 2 sessions, one is 
-- an image based session which does not conflict with a chat based session.
exec fuse.user('Provide a short creative sentence I can use to generate an image. Enclose your answer within <> angle brackets');
-- Generate the image.
exec fuse.image(p_prompt=>extract_text(fuse.response, '<', '>'), p_steps=>40);

-- You can check the results of above by checking session_image table and session_prompt table.

/*
Next example coming soon
*/


delete from log_table;
delete from fuse_session;
delete from json_data;
delete from session_prompt;
 
select * from provider_model;
select * from log_table where log_text like 'user%' order by 1 desc;
select * from json_data order by 1 desc;
select * from session_prompt order by 1 desc;
select * from session_image order by 1 desc;
select * from api_response;


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

