create or replace view alert__datapump_not_running as 
select 'warning' alert_level,
       'database' alert_type,
       owner_name||'_'||job_name||'_'||state alert_name,
       'attached_sessions='||attached_sessions||', datapump_sessions='||datapump_sessions alert_info,
       0 notify_interval,
       60 alert_delay
  from dba_datapump_jobs
 where state='NOT RUNNING';