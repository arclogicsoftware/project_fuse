create or replace package body app_api is

procedure post_request_all (
   p_request_id in varchar2,
   p_url in varchar2,
   p_data in clob) is 
   v_header_name varchar2(4000);
   v_header_val varchar2(4000);
begin
   debug('post_request_all: '||p_data);
   -- The entire response is stored in response global var. Use with caution of course.
   app_api.response := apex_web_service.make_rest_request (
      p_url         => p_url, 
      p_http_method => 'POST',
      p_body        => p_data);

   if app_api.verbose then
      for i in 1.. apex_web_service.g_headers.count loop
         v_header_name := apex_web_service.g_headers(i).name;
         v_header_val := apex_web_service.g_headers(i).value;
         dbms_output.put_line(v_header_name||': '||v_header_val);
         debug(v_header_name||': '||v_header_val);
      end loop;
   end if;

   last_status_code := apex_web_service.g_status_code;
   debug('last_status_code: '||last_status_code);
   debug('response: '||response);

   -- The response is parsed into individual rows in the json_data table.
   app_json.json_to_data_table (
      p_json_data=>response,
      p_json_key=>p_request_id);

   app_json.assert_no_errors (
      p_json_key=>p_request_id,
      p_error_path=>'root.error',
      p_error_type_path=>'root.error.type',
      p_error_message_path=>'root.error.message');

end;

procedure post_request (
   p_request_id in varchar2,
   p_x_api_key in varchar2,
   p_url in varchar2,
   p_data in clob) is 
begin
   apex_web_service.g_request_headers.delete();
   apex_web_service.g_request_headers(1).name := 'x-api-key';
   apex_web_service.g_request_headers(1).value := p_x_api_key; 
   apex_web_service.g_request_headers(2).name := 'Content-Type';
   apex_web_service.g_request_headers(2).value := 'application/json'; 
   post_request_all (
      p_request_id=>p_request_id,
      p_url=>p_url,
      p_data=>p_data);
end;

procedure post_request (
   p_request_id in varchar2,
   p_bearer_token in varchar2,
   p_url in varchar2,
   p_data in clob) is 
begin
   debug('post_request: '||p_bearer_token);
   apex_web_service.g_request_headers.delete();
   apex_web_service.g_request_headers(1).name := 'Authorization';
   apex_web_service.g_request_headers(1).value := 'Bearer '||p_bearer_token; 
   apex_web_service.g_request_headers(2).name := 'Content-Type';
   apex_web_service.g_request_headers(2).value := 'application/json'; 
   post_request_all (
      p_request_id=>p_request_id,
      p_url=>p_url,
      p_data=>p_data);
end;

end;
/
