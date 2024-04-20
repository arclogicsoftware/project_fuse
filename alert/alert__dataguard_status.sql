create or replace view alert__dataguard_status as
select distinct 
       'warning' alert_level,
       'dataguard_alert: '||message alert_name,
       null alert_info,
       'database' alert_type
  from gv$dataguard_status 
 where timestamp > systimestamp-(1/24) 
   and error_code != 0;

