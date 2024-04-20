create or replace package fuse as

   verbose boolean := true;
   last_response_json clob;
   last_status_code number;
   last_response_message clob;
   response clob;
   g_provider ai_provider%rowtype;
   g_model ai_model%rowtype;
   g_session ai_session%rowtype;

   -- Stores the last session used.
   g_last_session ai_session%rowtype;

   procedure set_session (
      p_session_name in varchar2);

   procedure create_session (
      p_session_name in varchar2,
      p_model_name in varchar2 default null,
      p_max_tokens in number default null,
      p_randomness in number default null,
      p_pause in number default null);

   procedure system (
      p_prompt in varchar2,
      p_session_name in varchar2 default null,
      p_exclude in number default 0);

   procedure assistant (
      p_prompt in varchar2,
      p_session_name in varchar2 default null,
      p_exclude in number default 0);

   procedure mock (
      p_prompt in varchar2,
      p_session_name in varchar2 default null,
      p_exclude in number default 0);

   procedure user (
      p_prompt in varchar2,
      p_session_name in varchar2 default null,
      p_response_id in varchar2 default null,
      p_schema in clob default null,
      p_exclude in number default 0,
      p_tools in clob default null);

   procedure tool (
      p_prompt in varchar2,
      p_function_name in varchar2,
      p_session_name in varchar2 default null,
      p_response_id in varchar2 default null,
      p_exclude in number default 0);

end;
/
