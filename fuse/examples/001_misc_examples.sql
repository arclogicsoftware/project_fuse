


-- ----------------------------------------------------------------------------
-- Raw api post.
-- Helpful if you need to try a fairly manual basic test of an API.
-- ----------------------------------------------------------------------------

begin
   fuse.post_api_request(
      p_request_id=>'test_request',
      p_api_url=>'https://api.groq.com/openai/v1/chat/completions',
      p_api_key=>fuse_config.groq_api_key,
      p_data=>'{"messages": [{"role": "user", "content": "Explain the importance of fast language models"}], "model": "mixtral-8x7b-32768"}');
end;
/

-- ----------------------------------------------------------------------------
-- Basic test that runs 1 or more models asks a basic question.
-- ----------------------------------------------------------------------------

declare
   -- Modify this to test specific models or all models.
   cursor models is select * from provider_model where model_name='mixtral-8x7b-32768' and model_type='chat';
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
end;
/

-- ----------------------------------------------------------------------------
-- Basic image model test.
-- Tested: https://docs.together.ai/docs/examples#image-generation
-- ----------------------------------------------------------------------------

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

-- ----------------------------------------------------------------------------
-- Extract text and image example.
-- ----------------------------------------------------------------------------

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

