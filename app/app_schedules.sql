
exec drop_scheduler_job('collect_stat_job');
begin
  if not does_scheduler_job_exist('collect_stat_job') then 
     dbms_scheduler.create_job (
       job_name        => 'collect_stat_job',
       job_type        => 'PLSQL_BLOCK',
       job_action      => 'begin collect_stat.collect; end;',
       start_date      => systimestamp,
       repeat_interval => 'freq=minutely;interval='||app_config.get_param_num('collect_stat_repeat_interval'),
       enabled         => true);
   end if;
end;
/

exec drop_scheduler_job('collect_table_sizes_job');

exec drop_scheduler_job('check_alert_job');
begin
  if not does_scheduler_job_exist('check_alert_job') then 
     dbms_scheduler.create_job (
       job_name        => 'check_alert_job',
       job_type        => 'PLSQL_BLOCK',
       job_action      => 'begin app_alert.check_alert_views; end;',
       start_date      => systimestamp,
       repeat_interval => 'freq=minutely;interval=10',
       enabled         => true);
   end if;
end;
/

exec drop_scheduler_job('monitor_sql_job');
begin
  if not does_scheduler_job_exist('monitor_sql_job') then 
     dbms_scheduler.create_job (
       job_name        => 'monitor_sql_job',
       job_type        => 'PLSQL_BLOCK',
       job_action      => 'begin sql_monitor.monitor; commit; end;',
       start_date      => systimestamp,
       repeat_interval => 'freq=minutely;interval=1',
       enabled         => true);
   end if;
end;
/

exec drop_scheduler_job('update_object_size_data_job');
begin
  if not does_scheduler_job_exist('update_object_size_data_job') then 
     dbms_scheduler.create_job (
       job_name        => 'update_object_size_data_job',
       job_type        => 'PLSQL_BLOCK',
       job_action      => 'begin update_object_size_data; commit; end;',
       start_date      => systimestamp,
       repeat_interval => 'freq=hourly;interval=24',
       enabled         => true);
   end if;
end;
/

exec drop_scheduler_job('check_sensor_views_job');
begin
  if not does_scheduler_job_exist('check_sensor_views_job') then 
     dbms_scheduler.create_job (
       job_name        => 'check_sensor_views_job',
       job_type        => 'PLSQL_BLOCK',
       job_action      => 'begin sensor.check_sensor_views; commit; end;',
       start_date      => systimestamp,
       repeat_interval => 'freq=hourly;interval=1',
       enabled         => true);
   end if;
end;
/

exec drop_scheduler_job('daily_am_job');
begin
  if not does_scheduler_job_exist('daily_am_job') then 
     dbms_scheduler.create_job (
       job_name        => 'daily_am_job',
       job_type        => 'PLSQL_BLOCK',
       job_action      => 'begin daily_am; commit; end;',
       start_date      => systimestamp,
       repeat_interval => 'freq=daily;byhour=8;byminute=0;bysecond=0',
       enabled         => true);
   end if;
end;
/

exec drop_scheduler_job('monitor_blocked_sessions_job');
begin
  if not does_scheduler_job_exist('monitor_blocked_sessions_job') then 
     dbms_scheduler.create_job (
       job_name        => 'monitor_blocked_sessions_job',
       job_type        => 'PLSQL_BLOCK',
       job_action      => 'begin monitor_blocked_sessions; commit; end;',
       start_date      => systimestamp,
       repeat_interval => 'freq=minutely;interval=5',
       enabled         => true);
   end if;
end;
/

exec drop_scheduler_job('run_minutely_job');
begin
  if not does_scheduler_job_exist('run_minutely_job') then 
     dbms_scheduler.create_job (
       job_name        => 'run_minutely_job',
       job_type        => 'PLSQL_BLOCK',
       job_action      => 'begin minutely_job; end;',
       start_date      => systimestamp,
       repeat_interval => 'freq=minutely;interval=1',
       enabled         => true);
   end if;
end;
/
