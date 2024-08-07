
exec drop_scheduler_job('collect_stat_job');
exec drop_scheduler_job('collect_table_sizes_job');
exec drop_scheduler_job('check_alert_job');
exec drop_scheduler_job('monitor_sql_job');
exec drop_scheduler_job('update_object_size_data_job');
exec drop_scheduler_job('check_sensor_views_job');
exec drop_scheduler_job('daily_am_job');
exec drop_scheduler_job('run_daily_am_job');
exec drop_scheduler_job('monitor_blocked_sessions_job');
exec drop_scheduler_job('update_sql_ptiles');
exec drop_scheduler_job('run_minutely_job');

@app/app_patch_pre.sql
@app/arcsql.sql
@app/app_schema.sql
@app/app_config.sql
@app/app_triggers.sql
@app/stat_table_before_update.sql
@app/collect_stat_pkgh.sql
@app/collect_stat_pkgb.sql
@app/app_alert.sql
@app/app_alert_pkgh.sql
@app/app_alert_pkgb.sql
@app/sql_monitor.sql
@app/sql_monitor_pkgh.sql
@app/sql_monitor_pkgb.sql
@app/sensor_pkgh.sql
@app/sensor_pkgb.sql
@app/app_format.sql
@app/app_json_pkgh.sql
@app/app_json_pkgb.sql
@app/app_api_pkgh.sql
@app/app_api_pkgb.sql
@app/app_test_pkgh.sql
@app/app_test_pkgb.sql
@app/update_object_size_data_proc.sql
@app/more_stat_stuff.sql
@stat/install_stats.sql
@view/install_views.sql
@alert/install_alerts.sql
@sensor/install_sensors.sql
@prc/install_prc.sql
@app/app_synonyms.sql
@app/app_schedules.sql
@app/backup_privs.sql
-- To be provided by customer.
@app/app_customer.sql

spool global_modifications.sql append
set head off 
set term off
set pages 0
set trims on 
set feed off
select null from dual;
spool off
set head on 
set term on
set pages 100
set trims off 
set feed on
@./global_modifications.sql

spool modifications.sql append
set head off 
set term off
set pages 0
set trims on 
set feed off
select null from dual;
spool off
set head on 
set term on
set pages 100
set trims off 
set feed on
@./modifications.sql

@app/app_patch_post.sql
@fuse/install_fuse.sql

begin 
   app_config.add_param_num(p_name=>'collect_stat_repeat_interval', p_num=>5);
   app_config.add_param_num(p_name=>'monitor_sql_repeat_interval', p_num=>15);
   app_config.add_param_num(p_name=>'small_table_gb_limit', p_num=>.1);
   app_config.add_param_num(p_name=>'object_size_data_min_mb', p_num=>100);
   app_config.add_param_num(p_name=>'collect_table_sizes_repeat_interval', p_num=>300);
   app_config.add_param_str(p_name=>'dump_table_dir', p_str=>null);
   
   -- When calc avg, med, and ptiles for SQL_LOG use this many days of history.
   app_config.add_param_num(p_name=>'sql_log_ref_days', p_num=>14);
   -- Do not calc the above until elap mins for all rows of force_matching_signature exceed this # of minutes.
   app_config.add_param_num(p_name=>'sql_log_ref_elapsed_mins_limit', p_num=>5);
    
   -- SENSORS
   app_config.add_param_num(p_name=>'sensor_purge_days', p_num=>365);
end;
/

select 'alter package '||object_name||' compile'||decode(object_type, 'PACKAGE BODY', ' body', '')||';' x
  from user_objects where status='INVALID'
   and object_type in ('PACKAGE','PACKAGE BODY')
union all
select 'alter '||object_type||' '||object_name||' compile;' x
  from user_objects where status='INVALID'
   and object_type in ('PROCEDURE', 'FUNCTION', 'TRIGGER', 'VIEW');

alter package sql_monitor compile body;
alter package app_alert compile body;
alter package sql_monitor compile body;
alter package app_alert compile body;
alter function sql_to_csv_pipe compile;
alter function sql_to_csv_clob compile;
alter procedure log_err compile;
alter procedure debug compile;
alter view alerts_ready_notify compile;
alter procedure assert compile;
alter procedure pass_test compile;
alter procedure fail_test compile;
alter procedure init_test compile;

select 'alter package '||object_name||' compile'||decode(object_type, 'PACKAGE BODY', ' body', '')||';' x
  from user_objects where status='INVALID'
   and object_type in ('PACKAGE','PACKAGE BODY')
union all
select 'alter '||object_type||' '||object_name||' compile;' x
  from user_objects where status='INVALID'
   and object_type in ('PROCEDURE', 'FUNCTION', 'TRIGGER', 'VIEW');
   
commit;

declare
   n number;
begin
   select count(*) into n from user_objects where status='INVALID';
   if n = 0 then 
      raise_application_error (-20001, '** SUCCESS **, No invalid objects, this is not an error!');
   else
      raise_application_error (-20001, '** ERROR ** - Check for invalid objects!');
   end if;
end;
/


