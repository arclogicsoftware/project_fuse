create or replace package fuse as

   randomness session_prompt.randomness%type default 1;
   max_tokens session_prompt.max_tokens%type default 1024;
   tool_group fuse_tool.tool_group%type;
   x clob;
   verbose boolean := true;

   last_response_json clob;
   last_response_message clob;
   response clob;

   -- Used for non images
   g_provider fuse_provider%rowtype;
   g_provider_api_key varchar2(512);
   g_model provider_model%rowtype;
   g_session fuse_session%rowtype;
   g_session_prompt session_prompt%rowtype;
   g_tool fuse_tool%rowtype;
   g_default_chat_model_name provider_model.model_name%type := 'codellama/CodeLlama-13b-Instruct-hf';
   

   -- Used for images
   g_image_provider fuse_provider%rowtype;
   g_image_provider_api_key varchar2(512);
   g_image_model provider_model%rowtype;
   g_image_session fuse_session%rowtype;
   g_default_image_model_name provider_model.model_name%type := 'stabilityai/stable-diffusion-2-1';

   input_prompt varchar2(4000);
   
   procedure make_rest_request(
      p_request_id in varchar2,
      p_api_url in varchar2,
      p_api_key in varchar2,
      p_data in clob);
   
   procedure init;

   procedure set_image_session (
      p_session_name in varchar2);

   procedure create_session (
      p_session_name in varchar2,
      p_model_name in varchar2,
      p_pause in number default null,
      p_steps in number default null,
      p_images in number default null);

   procedure input (
      p_prompt in varchar2 default null);

   function input return varchar2;

   function assert_true (
      p_assertion in varchar2) return boolean;

   procedure system (
      p_prompt in varchar2,
      p_session_name in varchar2 default fuse.g_session.session_name);

   procedure assistant (
      p_prompt in varchar2,
      p_session_name in varchar2 default fuse.g_session.session_name,
      p_exclude in boolean default false);

   procedure mock (
      p_prompt in varchar2,
      p_session_name in varchar2 default fuse.g_session.session_name);

   procedure user (
      p_prompt in varchar2,
      p_session_name in varchar2 default fuse.g_session.session_name,
      p_schema in clob default null,
      p_tool_group in varchar2 default null,
      p_exclude in boolean default false,
      p_randomness in number default null,
      p_max_tokens in number default null);

   procedure add_tool (
      p_tool_group in varchar2,
      p_function_name in varchar2,
      p_function_desc in varchar2,
      p_parm1 varchar2 default null,
      p_parm1_type varchar2 default null,
      p_parm1_desc varchar2 default null,
      p_parm1_req boolean default false,
      p_parm2 varchar2 default null,
      p_parm2_type varchar2 default null,
      p_parm2_desc varchar2 default null,
      p_parm2_req boolean default false);

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
