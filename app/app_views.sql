   
-- exec drop_view('sql_snap_view');
create or replace view sql_snap_view as (
 select sql_id,
        substr(sql_text, 1, 100) sql_text,
        plan_hash_value,
        force_matching_signature,
        sum(executions) executions,
        sum(elapsed_time) elapsed_time,
        sum(user_io_wait_time) user_io_wait_time,
        sum(rows_processed) rows_processed,
        sum(cpu_time) cpu_time,
        -- I don't thing the max is needed here as this should not be 
        -- a part of the uniqueness of the row but I need to ensure
        -- these values don't make a row unique and so I am taking
        -- max. Consider these values helpful but not 100% reliable.
        max(service) service,
        max(module) module,
        max(action) action
   from gv$sql
  where executions > 0
  group
     by sql_id,
        substr(sql_text, 1, 100),
        plan_hash_value,
        force_matching_signature
 having sum(elapsed_time) > = 1*1000000);

create or replace view sql_log_hourly_stat as
select trunc(datetime) sql_date,
       trunc(datetime, 'HH24') sql_hour,
       to_number(to_char(datetime,'HH24')) hh24,
       round(sum(elapsed_seconds)/60, 1) sql_elap_mins,
       -- sql_elap_mins_per_min
       round(sum(elapsed_seconds)/60/60, 1) active_sessions,
       round(sum(cpu_seconds)/60, 1) cpu_elap_mins,
       -- cpu_elap_mins_per_min
       round(sum(cpu_seconds)/60/60, 1) cpu_count_in_use,
       round(sum(user_io_wait_secs)/60, 1) user_io_wait_mins,
       round(sum(user_io_wait_secs)/60/60, 1) user_io_count,
       round(sum(executions)/60/60/1000, 1) sql_k_exe_per_sec,
       round(sum(rows_processed)/60/60/1000, 1) rows_k_per_sec,
       round(avg(elap_secs_per_exe), 2) avg_elap_secs_per_exe,
       round(sum(secs_0_1)/60 , 1) mins_0_1,
       round(sum(secs_2_5)/60 , 1) mins_2_5,
       round(sum(secs_6_10)/60 , 1) mins_6_10,
       round(sum(secs_11_60)/60 , 1) mins_11_60,
       round(sum(secs_61_plus)/60 , 1) mins_61_plus
  from sql_log 
 group 
    by trunc(datetime),
       trunc(datetime, 'HH24'),
       to_number(to_char(datetime,'HH24'))
/

create or replace view sql_log_weekly_stat as
select trunc(sql_date, 'iw') sql_date,
       round(avg(sql_elap_mins)) avg_sql_elap_mins,
       round(avg(active_sessions), 1) avg_active_sessions,
       round(avg(cpu_elap_mins)) avg_cpu_elap_mins,
       round(avg(cpu_count_in_use), 1) avg_cpu_count_in_use,
       round(avg(user_io_wait_mins)) avg_user_io_wait_mins,
       round(avg(user_io_count), 1) avg_user_io_count,
       round(avg(sql_k_exe_per_sec)) avg_sql_k_exe_per_sec,
       round(avg(rows_k_per_sec)) avg_rows_k_per_sec,
       round(avg(avg_elap_secs_per_exe), 1) avg_elap_secs_per_exe,
       round(avg(mins_0_1), 1) avg_mins_0_1,
       round(avg(mins_2_5), 1) avg_mins_2_5,
       round(avg(mins_6_10), 1) avg_mins_6_10,
       round(avg(mins_11_60), 1) avg_mins_11_60,
       round(avg(mins_61_plus), 1) avg_mins_61_plus
  from sql_log_hourly_stat
 group
    by trunc(sql_date, 'iw')
 order
    by 1 desc;
    
create or replace view sql_log_monthly_stat as
select trunc(sql_date, 'mon') sql_date,
       round(avg(sql_elap_mins)) avg_sql_elap_mins,
       round(avg(active_sessions), 1) avg_active_sessions,
       round(avg(cpu_elap_mins)) avg_cpu_elap_mins,
       round(avg(cpu_count_in_use), 1) avg_cpu_count_in_use,
       round(avg(user_io_wait_mins)) avg_user_io_wait_mins,
       round(avg(user_io_count), 1) avg_user_io_count,
       round(avg(sql_k_exe_per_sec)) avg_sql_k_exe_per_sec,
       round(avg(rows_k_per_sec)) avg_rows_k_per_sec,
       round(avg(avg_elap_secs_per_exe), 1) avg_elap_secs_per_exe,
       round(avg(mins_0_1), 1) avg_mins_0_1,
       round(avg(mins_2_5), 1) avg_mins_2_5,
       round(avg(mins_6_10), 1) avg_mins_6_10,
       round(avg(mins_11_60), 1) avg_mins_11_60,
       round(avg(mins_61_plus), 1) avg_mins_61_plus
  from sql_log_hourly_stat
 group
    by trunc(sql_date, 'mon')
 order
    by 1 desc;

    
create or replace view sql_log_sql_id_hourly_stat as
select sql_id,
       trunc(datetime) sql_date,
       trunc(datetime, 'HH24') sql_hour,
       to_number(to_char(datetime,'HH24')) hh24,
       round(sum(elapsed_seconds)/60, 1) sql_elap_mins,
       -- sql_elap_mins_per_min
       round(sum(elapsed_seconds)/60/60, 1) active_sessions,
       round(sum(cpu_seconds)/60, 1) cpu_elap_mins,
       -- cpu_elap_mins_per_min
       round(sum(cpu_seconds)/60/60, 1) cpu_count_in_use,
       round(sum(user_io_wait_secs)/60, 1) user_io_wait_mins,
       round(sum(user_io_wait_secs)/60/60, 1) user_io_count,
       round(sum(executions)/60/60/1000, 1) sql_k_exe_per_sec,
       round(sum(rows_processed)/60/60/1000, 1) rows_k_per_sec,
       round(avg(elap_secs_per_exe), 2) avg_elap_secs_per_exe,
       round(sum(secs_0_1)/60 , 1) mins_0_1,
       round(sum(secs_2_5)/60 , 1) mins_2_5,
       round(sum(secs_6_10)/60 , 1) mins_6_10,
       round(sum(secs_11_60)/60 , 1) mins_11_60,
       round(sum(secs_61_plus)/60 , 1) mins_61_plus
  from sql_log 
 group 
    by sql_id,
       trunc(datetime),
       trunc(datetime, 'HH24'),
       to_number(to_char(datetime,'HH24'));

create or replace view sql_log_sql_id_weekly_stat as
select sql_id,
       trunc(sql_date, 'iw') sql_date,
       round(avg(sql_elap_mins)) avg_sql_elap_mins,
       round(avg(active_sessions), 1) avg_active_sessions,
       round(avg(cpu_elap_mins)) avg_cpu_elap_mins,
       round(avg(cpu_count_in_use), 1) avg_cpu_count_in_use,
       round(avg(user_io_wait_mins)) avg_user_io_wait_mins,
       round(avg(user_io_count), 1) avg_user_io_count,
       round(avg(sql_k_exe_per_sec)) avg_sql_k_exe_per_sec,
       round(avg(rows_k_per_sec)) avg_rows_k_per_sec,
       round(avg(avg_elap_secs_per_exe), 1) avg_elap_secs_per_exe,
       round(avg(mins_0_1), 1) avg_mins_0_1,
       round(avg(mins_2_5), 1) avg_mins_2_5,
       round(avg(mins_6_10), 1) avg_mins_6_10,
       round(avg(mins_11_60), 1) avg_mins_11_60,
       round(avg(mins_61_plus), 1) avg_mins_61_plus
  from sql_log_sql_id_hourly_stat
 group
    by sql_id,
       trunc(sql_date, 'iw')
 order
    by 1, 2 desc;
    