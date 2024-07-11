
begin
   app_config.add_param_num(p_name=>'alert__datapump_running_long_hours', p_num=>12);
end;
/

create or replace view alert__datapump_running_long as 
select 'warning' alert_level,
       'database' alert_type,
       owner_name||'_'||job_name||'_'||state alert_name,
       'attached_sessions='||attached_sessions||', datapump_sessions='||datapump_sessions alert_info,
       0 notify_interval,
       app_config.get_param_num('alert__datapump_running_long_hours', 12)*60 alert_delay
  from dba_datapump_jobs
 where state != 'NOT RUNNING';

 