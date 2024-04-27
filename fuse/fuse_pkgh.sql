create or replace package fuse as

   verbose boolean := true;
   last_response_json clob;
   last_status_code number;
   last_response_message clob;
   response clob;
   g_provider fuse_provider%rowtype;
   g_provider_api_key varchar2(512);
   g_model provider_model%rowtype;
   g_session fuse_session%rowtype;

   -- Stores the last image model used when calling fuse.image. Subsequent calls to fuse.image will use this model if one is not specified.
   g_image_model_name provider_model.model_name%type;
   g_default_image_model_name provider_model.model_name%type := 'stabilityai/stable-diffusion-2-1';

   -- Stores the last session used.
   g_last_session fuse_session%rowtype;

   procedure set_session (
      p_session_name in varchar2);

   procedure create_session (
      p_session_name in varchar2,
      p_model_name in varchar2,
      p_max_tokens in number default null,
      p_randomness in number default null,
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
      p_tools in clob default null);

   procedure tool (
      p_prompt in varchar2,
      p_function_name in varchar2,
      p_session_name in varchar2 default fuse.g_session.session_name,
      p_response_id in varchar2 default null,
      p_exclude in number default 0);

   procedure image (
      p_prompt in varchar2,
      p_session_name in varchar2 default fuse.g_session.session_name,
      p_steps in number default 20,
      p_images in number default 1);

end;
/
