create or replace package fuse as

   tool_response clob;
   verbose boolean := false;

   last_response_json clob;
   response clob;

   last_status_code number;
   last_response_message clob;

   -- Used for non images
   g_provider fuse_provider%rowtype;
   g_provider_api_key varchar2(512);
   g_model provider_model%rowtype;
   g_session fuse_session%rowtype;
   g_session_prompt session_prompt%rowtype;
   g_tool_group tool_group%rowtype;
   g_tool fuse_tool%rowtype;
   -- Todo: not used
   g_default_chat_model_name provider_model.model_name%type := 'codellama/CodeLlama-13b-Instruct-hf';

   -- Used for images
   g_image_provider fuse_provider%rowtype;
   g_image_provider_api_key varchar2(512);
   g_image_model provider_model%rowtype;
   g_image_session fuse_session%rowtype;
   g_default_image_model_name provider_model.model_name%type := 'stabilityai/stable-diffusion-2-1';

   input_prompt varchar2(4000);
   
   procedure init;

   procedure set_session_model_provider (
      p_session_id in number);

   procedure set_image_session (
      p_session_name in varchar2);

   function does_session_exist (
      p_session_id in number) return boolean;

   procedure create_session (
      p_session_name in varchar2,
      p_model_name in varchar2,
      p_user_name in varchar2 default null,
      p_title in varchar2 default null,
      p_pause in number default 0,
      p_tool_group in varchar2 default null,
      p_steps in number default null,
      p_images in number default null);

   procedure request_session (
      p_session_name in varchar2,
      p_model_name in varchar2,
      p_user_name in varchar2 default null,
      p_pause in number default 0,
      p_steps in number default null,
      p_images in number default null);

   procedure input (
      p_prompt in varchar2 default null);

   function input return varchar2;

   function assert_true (
      p_assertion in varchar2) return boolean;

   procedure system (
      p_prompt in session_prompt.prompt%type,
      p_session_name in varchar2 default fuse.g_session.session_name);

   procedure assistant (
      p_prompt in session_prompt.prompt%type,
      p_session_name in varchar2 default fuse.g_session.session_name);

   procedure mock (
      p_prompt in varchar2,
      p_session_name in varchar2 default fuse.g_session.session_name);

   procedure user (
      p_prompt in varchar2,
      p_session_name in varchar2 default fuse.g_session.session_name);

   procedure chat (
      p_prompt in varchar2,
      p_session_name in varchar2 default fuse.g_session.session_name);

   procedure add_tool_group (
      p_tool_group in varchar2,
      p_desc in varchar2);

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
      p_arg2_req boolean default false);

   -- procedure image (
   --    p_prompt in varchar2,
   --    p_session_name in varchar2 default fuse.g_image_session.session_name,
   --    p_steps in number default 20,
   --    p_images in number default 1,
   --    p_width in number default 1024,
   --    p_height in number default 1024,
   --    p_seed in number default round(dbms_random.value(1,100)),
   --    p_negative_prompt in varchar2 default null);

end;
/
