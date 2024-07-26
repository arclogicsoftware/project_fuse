create or replace view alert__sql_text_slow_sql as
    select 'warning' alert_level,
           sql_text alert_name,
           'elapsed_hours='||round(sum_elapsed_seconds/60/60, 1) alert_info,
           'database' alert_type,
           0 alert_delay
     from (
select sql_text, 
       round(avg(elap_secs_per_exe_ptile), 1) avg_elap_secs_per_exe_ptile, 
       count(distinct datetime) distinct_hours, 
       count(distinct sql_id) distinct_sql_id,
       round(avg(fms_elapsed_seconds), 1) avg_fms_elapsed_seconds,
       round(avg(elapsed_seconds_ptile), 1) avg_elapsed_seconds_ptile,
       sum(elapsed_seconds) sum_elapsed_seconds,
       round(avg(elapsed_seconds), 1) avg_elapsed_seconds,
       max(elapsed_seconds) max_elapsed_seconds,
       max(datetime) max_datetime
  from sql_log 
 where 
       -- Take SQL within the last 4 hours into account
       update_time >= sysdate-(4/24)
       -- ptile range for both of these should be .8 or above
   and elap_secs_per_exe_ptile >=.8
   and elapsed_seconds_ptile >= .8
   and elap_secs_per_exe_ptile is not null
       -- per exe time should be at least 120% greater than these values
   and elap_secs_per_exe > (greatest(elap_secs_per_exe_avg, elap_secs_per_exe_med)*1.2) 
   and elap_secs_per_exe > sql_id_elap_secs_per_exe_ref*1.2
   and lower(sql_text) not like '%dbms_stats%'
 group
    by sql_text 
having count(distinct datetime) >= 2
   and sum(elapsed_seconds) > 1200);