-- Patch/fix
exec drop_scheduler_job('collect_stat_1h_job');
exec drop_scheduler_job('collect_stat_1m_job');
exec drop_scheduler_job('check_alert_5m_job');
exec drop_scheduler_job('monitor_sql_1m_job');
exec drop_package('alert_config');
exec drop_view('archive_log_distribution');
exec drop_view('alert__tablespace_pct_full');

delete from config_table where name='tablespace_percent_full_alert';
commit;

exec drop_procedure('run_alert_notify_rules');

exec drop_view('alert__flash_recovery_area_space');

exec drop_view('alerts_ready_notify');

exec drop_trigger('alert_can_notify_yn');

exec drop_view('blocked_is_blocked');

delete from config_table where name='default_alert_level';

delete from config_table where name='check_alert_repeat_interval';

exec drop_package('check_alert');

exec drop_table('tablespaces');

exec drop_view('alert__flash_reco_area_space');

begin
   drop_constraint('OBJ_SIZE_DATA_PK');
   drop_column('obj_size_data', 'host');
   drop_column('obj_size_data', 'dbid');
   drop_column('obj_size_data', 'db_name');
   if not does_constraint_exist('obj_size_data_pk_v2') then
      execute immediate 'alter table obj_size_data add constraint obj_size_data_pk_v2 primary key (owner, segment_name, partition_name, segment_type)';
   end if;
end;
/  

declare
   n number;
begin
   select max(size_in_gb)*.5 into n from sort_info;
   update config_table set value=n where name='large_sort_size_gb';
   commit;
end;
/

exec drop_view('alert__archive_dest_status');
exec drop_view('alert__archive_dest');

alter table sql_log modify (service varchar2(128));
alter table sql_log modify (module varchar2(128));
alter table sql_log modify (action varchar2(128));

exec drop_view('alert__arch_dest_status_time');
exec drop_view('archive_dest_status_time');
exec drop_view('alert__archive_dest_status_time');
exec drop_view('stat__dba_scheduler_job_run_details');

alter table alert_table modify (alert_level default 'warning');
update alert_table set alert_level='warning' where alert_level='warnings';

alter table sql_log modify (sql_text varchar2(256));
alter table sql_snap modify (sql_text varchar2(256));

exec drop_view('tablespace_space_monitor');

delete from config_table where name='alert__blocked_sessions_mins';
delete from config_table where name='alert__arch_dest_status_time_hours';
exec drop_view('alert__arch_dest_status_time');

-- Was not reliable
exec drop_view('alert__archive_dest_status_gap');
delete from config_table where name='alert__archive_dest_status_gap';

exec drop_view('alert__sql_slow_not_normal');

delete from config_table where name='alert__sql_slow_not_normal_elap_mins';
commit;

begin
   app_config.del_param(p_name=>'update_sql_ptile_elapsed_secs');
   app_config.del_param(p_name=>'update_sql_ptile_ref_days');
end;
/

exec drop_scheduler_job('update_sql_ptiles');

exec drop_procedure('execute_sql');

exec drop_procedure('apply_alert_rules');

commit;
