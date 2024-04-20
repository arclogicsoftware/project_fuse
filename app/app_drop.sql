
-- grep "^-- exec " * | awk '{print $2" "$3}'

exec drop_package('app_config');
exec drop_scheduler_job('collect_stat_1m_job');
exec drop_scheduler_job('check_alert_5m_job');
exec drop_scheduler_job('monitor_sql_1m_job');
exec drop_scheduler_job('collect_stat_1h_job');
exec drop_table('alert_table');
exec drop_table('stat_table');
exec drop_table('sql_snap');
exec drop_table('sql_log');
exec drop_view('table_size_summary');
exec drop_view('sort_info');
exec drop_view('all_sorts');
exec drop_view('sql_snap_view');
exec drop_view('archive_log_dist');
exec drop_view('tsinfo');
exec drop_view('table_stats');
exec drop_view('locked_objects');
exec drop_view('lockers');
exec drop_package('check_alert');
exec drop_package('collect_stat');
exec drop_package('sql_monitor');
exec drop_view('example_view');
exec drop_view('alert__example_view');
exec drop_procedure('stat__example');


-- grep "^-- drop " * | awk '{print $2" "$3" " $4}'

drop procedure execute_sql;
drop procedure drop_object;
drop function does_object_exist;
drop procedure drop_view;
drop procedure drop_function;
drop procedure drop_procedure;
drop procedure drop_type;
drop function does_package_exist;
drop function does_procedure_exist;
drop procedure drop_package;
drop function does_table_exist;
drop function does_column_exist;
drop function is_column_nullable;
drop procedure drop_column;
drop function does_index_exist;
drop function does_constraint_exist;
drop procedure add_primary_key;
drop procedure drop_constraint;
drop procedure drop_index;
drop procedure drop_table;
drop function does_sequence_exist;
drop procedure drop_sequence;
drop procedure create_sequence;
drop function does_scheduler_job_exist;
drop procedure drop_scheduler_job;
drop function num_get_val_from_sql;
drop function does_database_account_exist;
drop procedure fix_identity_sequences;
