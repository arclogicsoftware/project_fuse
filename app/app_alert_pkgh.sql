
-- exec drop_package('app_alert');
create or replace package app_alert is 
   
   type timer_type is table of date index by varchar2(120);
   
   g_timer timer_type;

   procedure evaluate_alerts;
   
   function get_notify_count (
      p_alert_name in varchar2, 
      p_hours in number default 0) return number;
   
   procedure open_alert (
      p_alert_name in varchar2,
      p_alert_type in varchar2 default null,
      p_alert_level in varchar2 default 'warning',
      p_alert_info in varchar2 default null,
      p_alert_view in varchar2 default null);

   procedure close_alert (
      p_alert_name in varchar2,
      p_alert_type in varchar2 default null);

   procedure check_alert_views;
   
end;
/
