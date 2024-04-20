create or replace view alert__startup_time as
select 'warning' alert_level,
       'startup_time_changed' alert_name,
       instance_name||' ('||inst_id||') started at '||round((sysdate-startup_time)*24*60)||' minutes ago.' alert_info,
       'database' alert_type
 from gv$instance
where (sysdate-startup_time)*24*60 < 60;