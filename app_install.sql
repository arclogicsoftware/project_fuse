
exec drop_scheduler_job('collect_stat_job');
exec drop_scheduler_job('collect_table_sizes_job');
exec drop_scheduler_job('check_alert_job');
exec drop_scheduler_job('monitor_sql_job');
exec drop_scheduler_job('update_object_size_data_job');
exec drop_scheduler_job('check_sensor_views_job');
exec drop_scheduler_job('daily_am_job');
exec drop_scheduler_job('monitor_blocked_sessions_job');
exec drop_scheduler_job('update_sql_ptiles');
exec drop_scheduler_job('run_minutely_job');

@app/app_patch.sql
@app/arcsql.sql
@app/app_schema.sql
@app/app_config.sql
@app/app_views.sql
@app/app_triggers.sql
@app/stat_table_before_update.sql
@app/collect_stat_pkgh.sql
@app/collect_stat_pkgb.sql
@app/app_alert_procs.sql
@app/app_alert_pkgh.sql
@app/app_alert_pkgb.sql
@app/sql_monitor_pkgh.sql
@app/sql_monitor_pkgb.sql
@app/sensor_pkgh.sql
@app/sensor_pkgb.sql
@app/assert_pkgh.sql
@app/assert_pkgb.sql
@app/app_format.sql
@app/app_json_pkgh.sql
@app/app_json_pkgb.sql
@app/app_api_pkgh.sql
@app/app_api_pkgb.sql
@app/app_procs.sql
@app/update_object_size_data_proc.sql
@app/more_stat_stuff.sql
@stat/install_stats.sql
@sql/install_sql.sql
@alert/install_alerts.sql
@sensor/install_sensors.sql
@prc/install_prc.sql
@app/app_synonyms.sql
@app/app_schedules.sql
@app/app_tests.sql
@app/backup_privs.sql
-- To be provided by customer.
@app/app_customer.sql

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
end;
/

select 'alter package '||object_name||' compile'||decode(object_type, 'PACKAGE BODY', ' body', '')||';' x
  from user_objects where status='INVALID'
   and object_type in ('PACKAGE','PACKAGE BODY')
union all
select 'alter '||object_type||' '||object_name||' compile;' x
  from user_objects where status='INVALID'
   and object_type in ('PROCEDURE', 'FUNCTION', 'TRIGGER', 'VIEW');

alter package SQL_MONITOR compile body;
alter package APP_ALERT compile body;
alter package SQL_MONITOR compile body;
alter package APP_ALERT compile body;
alter FUNCTION SQL_TO_CSV_PIPE compile;
alter FUNCTION SQL_TO_CSV_CLOB compile;
alter PROCEDURE LOG_ERR compile;
alter PROCEDURE DEBUG compile;
alter VIEW ALERTS_NOTIFY_REPORT compile;

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


