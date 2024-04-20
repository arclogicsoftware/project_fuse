create or replace package app_api is
   verbose boolean := false;
   response clob;
   last_status_code number;
   last_response_message clob;

   procedure post_request (
      p_request_id in varchar2,
      p_x_api_key in varchar2,
      p_url in varchar2,
      p_data in clob);

   procedure post_request (
      p_request_id in varchar2,
      p_bearer_token in varchar2,
      p_url in varchar2,
      p_data in clob);
end;
/
