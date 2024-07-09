-- This procedure needs to be customized and added to modifications.sql to implement.
create or replace procedure send_email ( 
   p_to in varchar2, 
   p_from in varchar2, 
   p_body in varchar2,
   p_subject in varchar2
   ) is
   v_to varchar2(256) := lower(p_to);
begin
   -- This line needs to be added for Maxapex.
   -- Update: 2/22/2022 Setting this caused erratic behavior in the return for apex_page.get_url.
   -- It would return full url with domain and change from f= type of url to pretty url. 
   -- Sending email from Maxapex seems to work without this being set.
   -- wwv_flow_api.set_security_group_id;
   -- apex_mail.send(
   --    p_to=>v_to,
   --    p_from=>p_from,
   --    p_subj=>p_subject,
   --    p_body=>p_body,
   --    p_body_html=>p_body
   --    );
   -- apex_mail.push_queue;
   null;
end;
/

