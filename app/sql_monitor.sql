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
    


create or replace view sql_log_hourly_crosstab as
select sql_text,
       round(sum(tim0)/60, 0) mins0_elap_12am,
       round(sum(tim1)/60, 1) mins1,
       round(sum(tim2)/60, 1) mins2,
       round(sum(tim3)/60, 1) mins3,
       round(sum(tim4)/60, 1) mins4,
       round(sum(tim5)/60, 1) mins5,
       round(sum(tim6)/60, 1) mins6,
       round(sum(tim7)/60, 1) mins7,
       round(sum(tim8)/60, 1) mins8,
       round(sum(tim9)/60, 1) mins9,
       round(sum(tim10)/60, 1) mins10,
       round(sum(tim11)/60, 1) mins11,
       round(sum(tim12)/60, 1) mins12,
       round(sum(tim13)/60, 1) mins13,
       round(sum(tim14)/60, 1) mins14,
       round(sum(tim15)/60, 1) mins15,
       round(sum(tim16)/60, 1) mins16,
       round(sum(tim17)/60, 1) mins17,
       round(sum(tim18)/60, 1) mins18,
       round(sum(tim19)/60, 1) mins19,
       round(sum(tim20)/60, 1) mins20,
       round(sum(tim21)/60, 1) mins21,
       round(sum(tim22)/60, 1) mins22,
       round(sum(tim23)/60, 1) mins23,
       round(sum(total)/60, 1) total,
       round(sum(total)/60/24, 1) mins_avg,
       round(avg(avg0), 3) secs0_per_exe_12am,
       round(avg(avg1), 3) secs1,
       round(avg(avg2), 3) secs2,
       round(avg(avg3), 3) secs3,
       round(avg(avg4), 3) secs4,
       round(avg(avg5), 3) secs5,
       round(avg(avg6), 3) secs6,
       round(avg(avg7), 3) secs7,
       round(avg(avg8), 3) secs8,
       round(avg(avg9), 3) secs9,
       round(avg(avg10), 1) secs10,
       round(avg(avg11), 1) secs11,
       round(avg(avg12), 1) secs12,
       round(avg(avg13), 1) secs13,
       round(avg(avg14), 1) secs14,
       round(avg(avg15), 1) secs15,
       round(avg(avg16), 1) secs16,
       round(avg(avg17), 1) secs17,
       round(avg(avg18), 1) secs18,
       round(avg(avg19), 1) secs19,
       round(avg(avg20), 1) secs20,
       round(avg(avg21), 1) secs21,
       round(avg(avg22), 1) secs22,
       round(avg(avg23), 1) secs23,
       round(sum(exe0/1000), 1) exe0_k_12am,
       round(sum(exe1/1000), 1) exe1,
       round(sum(exe2/1000), 1) exe2,
       round(sum(exe3/1000), 1) exe3,
       round(sum(exe4/1000), 1) exe4,
       round(sum(exe5/1000), 1) exe5,
       round(sum(exe6/1000), 1) exe6,
       round(sum(exe7/1000), 1) exe7,
       round(sum(exe8/1000), 1) exe8,
       round(sum(exe9/1000), 1) exe9,
       round(sum(exe10/1000), 1) exe10,
       round(sum(exe11/1000), 1) exe11,
       round(sum(exe12/1000), 1) exe12,
       round(sum(exe13/1000), 1) exe13,
       round(sum(exe14/1000), 1) exe14,
       round(sum(exe15/1000), 1) exe15,
       round(sum(exe16/1000), 1) exe16,
       round(sum(exe17/1000), 1) exe17,
       round(sum(exe18/1000), 1) exe18,
       round(sum(exe19/1000), 1) exe19,
       round(sum(exe20/1000), 1) exe20,
       round(sum(exe21/1000), 1) exe21,
       round(sum(exe22/1000), 1) exe22,
       round(sum(exe23/1000), 1) exe23
  from 
(
select sql_text,
       decode(w, 0, elapsed_seconds, 0) tim0,
       decode(w, 1, elapsed_seconds, 0) tim1,
       decode(w, 2, elapsed_seconds, 0) tim2,
       decode(w, 3, elapsed_seconds, 0) tim3,
       decode(w, 4, elapsed_seconds, 0) tim4,
       decode(w, 5, elapsed_seconds, 0) tim5,
       decode(w, 6, elapsed_seconds, 0) tim6,
       decode(w, 7, elapsed_seconds, 0) tim7,
       decode(w, 8, elapsed_seconds, 0) tim8,
       decode(w, 9, elapsed_seconds, 0) tim9,
       decode(w, 10, elapsed_seconds, 0) tim10,
       decode(w, 11, elapsed_seconds, 0) tim11,
       decode(w, 12, elapsed_seconds, 0) tim12,
       decode(w, 13, elapsed_seconds, 0) tim13,
       decode(w, 14, elapsed_seconds, 0) tim14,
       decode(w, 15, elapsed_seconds, 0) tim15,
       decode(w, 16, elapsed_seconds, 0) tim16,
       decode(w, 17, elapsed_seconds, 0) tim17,
       decode(w, 18, elapsed_seconds, 0) tim18,
       decode(w, 19, elapsed_seconds, 0) tim19,
       decode(w, 20, elapsed_seconds, 0) tim20,
       decode(w, 21, elapsed_seconds, 0) tim21,
       decode(w, 22, elapsed_seconds, 0) tim22,
       decode(w, 23, elapsed_seconds, 0) tim23,
       elapsed_seconds total,
       decode(w, 0, elapsed_seconds/executions, 0) avg0,
       decode(w, 1, elapsed_seconds/executions, 0) avg1,
       decode(w, 2, elapsed_seconds/executions, 0) avg2,
       decode(w, 3, elapsed_seconds/executions, 0) avg3,
       decode(w, 4, elapsed_seconds/executions, 0) avg4,
       decode(w, 5, elapsed_seconds/executions, 0) avg5,
       decode(w, 6, elapsed_seconds/executions, 0) avg6,
       decode(w, 7, elapsed_seconds/executions, 0) avg7,
       decode(w, 8, elapsed_seconds/executions, 0) avg8,
       decode(w, 9, elapsed_seconds/executions, 0) avg9,
       decode(w, 10, elapsed_seconds/executions, 0) avg10,
       decode(w, 11, elapsed_seconds/executions, 0) avg11,
       decode(w, 12, elapsed_seconds/executions, 0) avg12,
       decode(w, 13, elapsed_seconds/executions, 0) avg13,
       decode(w, 14, elapsed_seconds/executions, 0) avg14,
       decode(w, 15, elapsed_seconds/executions, 0) avg15,
       decode(w, 16, elapsed_seconds/executions, 0) avg16,
       decode(w, 17, elapsed_seconds/executions, 0) avg17,
       decode(w, 18, elapsed_seconds/executions, 0) avg18,
       decode(w, 19, elapsed_seconds/executions, 0) avg19,
       decode(w, 20, elapsed_seconds/executions, 0) avg20,
       decode(w, 21, elapsed_seconds/executions, 0) avg21,
       decode(w, 22, elapsed_seconds/executions, 0) avg22,
       decode(w, 23, elapsed_seconds/executions, 0) avg23,
       decode(w, 0, executions, 0) exe0,
       decode(w, 1, executions, 0) exe1,
       decode(w, 2, executions, 0) exe2,
       decode(w, 3, executions, 0) exe3,
       decode(w, 4, executions, 0) exe4,
       decode(w, 5, executions, 0) exe5,
       decode(w, 6, executions, 0) exe6,
       decode(w, 7, executions, 0) exe7,
       decode(w, 8, executions, 0) exe8,
       decode(w, 9, executions, 0) exe9,
       decode(w, 10, executions, 0) exe10,
       decode(w, 11, executions, 0) exe11,
       decode(w, 12, executions, 0) exe12,
       decode(w, 13, executions, 0) exe13,
       decode(w, 14, executions, 0) exe14,
       decode(w, 15, executions, 0) exe15,
       decode(w, 16, executions, 0) exe16,
       decode(w, 17, executions, 0) exe17,
       decode(w, 18, executions, 0) exe18,
       decode(w, 19, executions, 0) exe19,
       decode(w, 20, executions, 0) exe20,
       decode(w, 21, executions, 0) exe21,
       decode(w, 22, executions, 0) exe22,
       decode(w, 23, executions, 0) exe23
  from (
select sql_text,
       to_number(to_char(datetime, 'HH24')) w, 
       elapsed_seconds,
       executions
  from sql_log
 where datetime > trunc(sysdate-1, 'HH24'))
 )
 group
    by sql_text
 order by 26 desc;

create or replace view sql_log_daily_crosstab as
select sql_text,
       round(sum(tim0)/60/60, 1) hrs0_elap_today,
       round(sum(tim1)/60/60, 1) hrs1,
       round(sum(tim2)/60/60, 1) hrs2,
       round(sum(tim3)/60/60, 1) hrs3,
       round(sum(tim4)/60/60, 1) hrs4,
       round(sum(tim5)/60/60, 1) hrs5,
       round(sum(tim6)/60/60, 1) hrs6,
       round(sum(total)/60/60, 1) hrs_total,
       round(sum(total)/60/60/7, 1) hrs_avg,
       round(avg(avg0), 1) secs0_per_exe_today,
       round(avg(avg1), 1) secs1,
       round(avg(avg2), 1) secs2,
       round(avg(avg3), 1) secs3,
       round(avg(avg4), 1) secs4,
       round(avg(avg5), 1) secs5,
       round(avg(avg6), 1) secs6,
       round(sum(exe0/1000), 1) exe0_k_today,
       round(sum(exe1/1000), 1) exe1,
       round(sum(exe2/1000), 1) exe2,
       round(sum(exe3/1000), 1) exe3,
       round(sum(exe4/1000), 1) exe4,
       round(sum(exe5/1000), 1) exe5,
       round(sum(exe6/1000), 1) exe6
  from (
select sql_text,
       decode(w, 0, elapsed_seconds, 0) tim0,
       decode(w, 1, elapsed_seconds, 0) tim1,
       decode(w, 2, elapsed_seconds, 0) tim2,
       decode(w, 3, elapsed_seconds, 0) tim3,
       decode(w, 4, elapsed_seconds, 0) tim4,
       decode(w, 5, elapsed_seconds, 0) tim5,
       decode(w, 6, elapsed_seconds, 0) tim6,
       decode(w, 7, elapsed_seconds, 0) tim7,
       decode(w, 8, elapsed_seconds, 0) tim8,
       elapsed_seconds total,
       decode(w, 0, elapsed_seconds/executions, 0) avg0,
       decode(w, 1, elapsed_seconds/executions, 0) avg1,
       decode(w, 2, elapsed_seconds/executions, 0) avg2,
       decode(w, 3, elapsed_seconds/executions, 0) avg3,
       decode(w, 4, elapsed_seconds/executions, 0) avg4,
       decode(w, 5, elapsed_seconds/executions, 0) avg5,
       decode(w, 6, elapsed_seconds/executions, 0) avg6,
       decode(w, 7, elapsed_seconds/executions, 0) avg7,
       decode(w, 8, elapsed_seconds/executions, 0) avg8,
       decode(w, 0, executions, 0) exe0,
       decode(w, 1, executions, 0) exe1,
       decode(w, 2, executions, 0) exe2,
       decode(w, 3, executions, 0) exe3,
       decode(w, 4, executions, 0) exe4,
       decode(w, 5, executions, 0) exe5,
       decode(w, 6, executions, 0) exe6,
       decode(w, 7, executions, 0) exe7,
       decode(w, 8, executions, 0) exe8
  from (
select sql_text,
       round((trunc(sysdate)-trunc(datetime))) w,
       elapsed_seconds,
       executions
  from sql_log
 where round((trunc(sysdate)-trunc(datetime))) <=6 
   and datetime >= trunc(sysdate) - (8)))
 group
    by sql_text
 order by 2 desc;

 create or replace view sql_log_weekly_crosstab as
select sql_text,
       round(sum(tim0)/60/60, 1) hrs0_elap_this_wk,
       round(sum(tim1)/60/60, 1) hrs1,
       round(sum(tim2)/60/60, 1) hrs2,
       round(sum(tim3)/60/60, 1) hrs3,
       round(sum(tim4)/60/60, 1) hrs4,
       round(sum(tim5)/60/60, 1) hrs5,
       round(sum(tim6)/60/60, 1) hrs6,
       round(sum(total)/60/60, 1) hrs_total,
       round(sum(total)/60/60/7, 1) hrs_avg,
       round(avg(avg0), 1) secs0_per_exe_this_wk,
       round(avg(avg1), 1) secs1,
       round(avg(avg2), 1) secs2,
       round(avg(avg3), 1) secs3,
       round(avg(avg4), 1) secs4,
       round(avg(avg5), 1) secs5,
       round(avg(avg6), 1) secs6,
       round(sum(exe0/1000), 1) exe0_k_this_wk,
       round(sum(exe1/1000), 1) exe1,
       round(sum(exe2/1000), 1) exe2,
       round(sum(exe3/1000), 1) exe3,
       round(sum(exe4/1000), 1) exe4,
       round(sum(exe5/1000), 1) exe5,
       round(sum(exe6/1000), 1) exe6
  from (
select sql_text,
       decode(w, 0, elapsed_seconds, 0) tim0,
       decode(w, 1, elapsed_seconds, 0) tim1,
       decode(w, 2, elapsed_seconds, 0) tim2,
       decode(w, 3, elapsed_seconds, 0) tim3,
       decode(w, 4, elapsed_seconds, 0) tim4,
       decode(w, 5, elapsed_seconds, 0) tim5,
       decode(w, 6, elapsed_seconds, 0) tim6,
       decode(w, 7, elapsed_seconds, 0) tim7,
       decode(w, 8, elapsed_seconds, 0) tim8,
       elapsed_seconds total,
       decode(w, 0, elapsed_seconds/executions, 0) avg0,
       decode(w, 1, elapsed_seconds/executions, 0) avg1,
       decode(w, 2, elapsed_seconds/executions, 0) avg2,
       decode(w, 3, elapsed_seconds/executions, 0) avg3,
       decode(w, 4, elapsed_seconds/executions, 0) avg4,
       decode(w, 5, elapsed_seconds/executions, 0) avg5,
       decode(w, 6, elapsed_seconds/executions, 0) avg6,
       decode(w, 7, elapsed_seconds/executions, 0) avg7,
       decode(w, 8, elapsed_seconds/executions, 0) avg8,
       decode(w, 0, executions, 0) exe0,
       decode(w, 1, executions, 0) exe1,
       decode(w, 2, executions, 0) exe2,
       decode(w, 3, executions, 0) exe3,
       decode(w, 4, executions, 0) exe4,
       decode(w, 5, executions, 0) exe5,
       decode(w, 6, executions, 0) exe6,
       decode(w, 7, executions, 0) exe7,
       decode(w, 8, executions, 0) exe8
  from (
select sql_text,
       round((trunc(sysdate)-trunc(datetime))/7) w,
       elapsed_seconds,
       executions
  from sql_log
 where round((trunc(sysdate)-trunc(datetime))/7) <= 6
   and datetime >= sysdate - (7*7)))
 group
    by sql_text
 order by 2 desc;


create or replace view sql_log_monthly_crosstab as
select sql_text,
       round(sum(tim1)/60/60, 1) hrs1_elap_jan,
       round(sum(tim2)/60/60, 1) hrs2,
       round(sum(tim3)/60/60, 1) hrs3,
       round(sum(tim4)/60/60, 1) hrs4,
       round(sum(tim5)/60/60, 1) hrs5,
       round(sum(tim6)/60/60, 1) hrs6,
       round(sum(tim7)/60/60, 1) hrs7,
       round(sum(tim8)/60/60, 1) hrs8,
       round(sum(tim9)/60/60, 1) hrs9,
       round(sum(tim10)/60/60, 1) hrs10,
       round(sum(tim11)/60/60, 1) hrs11,
       round(sum(tim12)/60/60, 1) hrs12,
       round(sum(total)/60/60, 1) hrs_total,
       round(avg(avg1), 3) secs1_per_exe_jan,
       round(avg(avg2), 3) secs2,
       round(avg(avg3), 3) secs3,
       round(avg(avg4), 3) secs4,
       round(avg(avg5), 3) secs5,
       round(avg(avg6), 3) secs6,
       round(avg(avg7), 3) secs7,
       round(avg(avg8), 3) secs8,
       round(avg(avg9), 3) secs9,
       round(avg(avg10), 1) secs10,
       round(avg(avg11), 1) secs11,
       round(avg(avg12), 1) secs12,
       round(sum(exe1/1000), 1) exe1_k_jan,
       round(sum(exe2/1000), 1) exe2,
       round(sum(exe3/1000), 1) exe3,
       round(sum(exe4/1000), 1) exe4,
       round(sum(exe5/1000), 1) exe5,
       round(sum(exe6/1000), 1) exe6,
       round(sum(exe7/1000), 1) exe7,
       round(sum(exe8/1000), 1) exe8,
       round(sum(exe9/1000), 1) exe9,
       round(sum(exe10/1000), 1) exe10,
       round(sum(exe11/1000), 1) exe11,
       round(sum(exe11/1000), 1) exe12
  from (
select sql_text,
       decode(w, 1, elapsed_seconds, 0) tim1,
       decode(w, 2, elapsed_seconds, 0) tim2,
       decode(w, 3, elapsed_seconds, 0) tim3,
       decode(w, 4, elapsed_seconds, 0) tim4,
       decode(w, 5, elapsed_seconds, 0) tim5,
       decode(w, 6, elapsed_seconds, 0) tim6,
       decode(w, 7, elapsed_seconds, 0) tim7,
       decode(w, 8, elapsed_seconds, 0) tim8,
       decode(w, 9, elapsed_seconds, 0) tim9,
       decode(w, 10, elapsed_seconds, 0) tim10,
       decode(w, 11, elapsed_seconds, 0) tim11,
       decode(w, 12, elapsed_seconds, 0) tim12,
       elapsed_seconds total,
       decode(w, 1, elapsed_seconds/executions, 0) avg1,
       decode(w, 2, elapsed_seconds/executions, 0) avg2,
       decode(w, 3, elapsed_seconds/executions, 0) avg3,
       decode(w, 4, elapsed_seconds/executions, 0) avg4,
       decode(w, 5, elapsed_seconds/executions, 0) avg5,
       decode(w, 6, elapsed_seconds/executions, 0) avg6,
       decode(w, 7, elapsed_seconds/executions, 0) avg7,
       decode(w, 8, elapsed_seconds/executions, 0) avg8,
       decode(w, 9, elapsed_seconds/executions, 0) avg9,
       decode(w, 10, elapsed_seconds/executions, 0) avg10,
       decode(w, 11, elapsed_seconds/executions, 0) avg11,
       decode(w, 12, elapsed_seconds/executions, 0) avg12,
       decode(w, 1, executions, 0) exe1,
       decode(w, 2, executions, 0) exe2,
       decode(w, 3, executions, 0) exe3,
       decode(w, 4, executions, 0) exe4,
       decode(w, 5, executions, 0) exe5,
       decode(w, 6, executions, 0) exe6,
       decode(w, 7, executions, 0) exe7,
       decode(w, 8, executions, 0) exe8,
       decode(w, 9, executions, 0) exe9,
       decode(w, 10, executions, 0) exe10,
       decode(w, 11, executions, 0) exe11,
       decode(w, 12, executions, 0) exe12
  from (
select sql_text,
       to_number(to_char(datetime, 'MM')) w, 
       elapsed_seconds,
       executions
  from sql_log
 where datetime >= add_months(trunc(sysdate, 'MM'), -11)))
 group
    by sql_text
 order by 2 desc;

