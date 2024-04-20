create or replace view alert__dba_outstanding_alerts as
select lower(message_type) alert_level,
       reason alert_name,
       suggested_action alert_info,
       'dba_outstanding_alerts' alert_type
 from dba_outstanding_alerts;
