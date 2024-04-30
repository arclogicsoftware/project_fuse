create or replace package fuse as

   verbose boolean := true;

   last_response_json clob;
   last_response_message clob;
   response clob;

   -- Used for non images
   g_provider fuse_provider%rowtype;
   g_provider_api_key varchar2(512);
   g_model provider_model%rowtype;
   g_session fuse_session%rowtype;
   g_default_chat_model_name provider_model.model_name%type := 'codellama/CodeLlama-13b-Instruct-hf';
   randomness number default 1;
   max_tokens number default 1024;

   -- Used for images
   g_image_provider fuse_provider%rowtype;
   g_image_provider_api_key varchar2(512);
   g_image_model provider_model%rowtype;
   g_image_session fuse_session%rowtype;
   g_default_image_model_name provider_model.model_name%type := 'stabilityai/stable-diffusion-2-1';
   
   procedure post_api_request (
      p_request_id in varchar2,
      p_api_url in varchar2,
      p_api_key in varchar2,
      p_data in clob);
   
   procedure init;

   procedure set_session (
      p_session_name in varchar2);

   procedure set_image_session (
      p_session_name in varchar2);

   procedure create_session (
      p_session_name in varchar2,
      p_model_name in varchar2,
      p_pause in number default null,
      p_steps in number default null,
      p_images in number default null);

   procedure system (
      p_prompt in varchar2,
      p_session_name in varchar2 default fuse.g_session.session_name,
      p_exclude in number default 0);

   procedure assistant (
      p_prompt in varchar2,
      p_session_name in varchar2 default fuse.g_session.session_name,
      p_exclude in number default 0);

   procedure mock (
      p_prompt in varchar2,
      p_session_name in varchar2 default fuse.g_session.session_name,
      p_exclude in number default 0);

   procedure user (
      p_prompt in varchar2,
      p_session_name in varchar2 default fuse.g_session.session_name,
      p_response_id in varchar2 default null,
      p_schema in clob default null,
      p_exclude in number default 0,
      p_tools in clob default null,
      p_randomness in number default null,
      p_max_tokens in number default null);

   procedure tool (
      p_prompt in varchar2,
      p_function_name in varchar2,
      p_session_name in varchar2 default fuse.g_session.session_name,
      p_response_id in varchar2 default null,
      p_exclude in number default 0);

   procedure image (
      p_prompt in varchar2,
      p_session_name in varchar2 default fuse.g_image_session.session_name,
      p_steps in number default 20,
      p_images in number default 1,
      p_width in number default 1024,
      p_height in number default 1024,
      p_seed in number default round(dbms_random.value(1,100)),
      p_negative_prompt in varchar2 default null);

end;
/
