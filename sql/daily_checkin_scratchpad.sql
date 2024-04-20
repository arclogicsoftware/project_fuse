
declare  
  h number;  
 begin  
  h := dbms_datapump.open( operation => 'export', job_mode => 'schema', job_name=>null);  
  dbms_datapump.add_file( handle => h, filename => 'objects.dmp', directory => 'data_pump_dir', filetype => dbms_datapump.ku$_file_type_dump_file);  
  dbms_datapump.add_file( handle => h, filename => 'objects.log', directory => 'data_pump_dir', filetype => dbms_datapump.ku$_file_type_log_file);  
  dbms_datapump.metadata_filter(h,'schema_expr','in (''PRODDTA'')');  
  dbms_datapump.metadata_filter( handle => h ,name   => 'name_expr',value  =>  q'| in ('F0911','F1201','F1202')|',object_path=> 'table' ); 
  dbms_datapump.start_job(h);  
  end;  
/  

select created "G-DATE" from dba_objects where object_name='TEST_TABLE';


select username,
       count(*),
       last_call_days
  from (
select username,
       round(last_call_et/86400) last_call_days
  from gv$session)
group
  by username,
     last_call_days
order by 2 desc;


select username, module, program, trunc(logon_time), count(*) 
  from v$session 
  where program not like 'oracle@%' group by trunc(logon_time), username, module, program order by 5 desc;

-- Check for SQL not using bind variables
select count(*), substr(sql_text, 1, 40) from v$sql group by substr(sql_text, 1, 40) order by 1 desc;

select * from obj_size_data where segment_name in ('F01131', 'F01131T',  'F01131M', 'F01133', 'F00165',  'F00166')
 order by last_size desc;
select count(*), zmdti from proddta.f01131m group by zmdti order by 2 desc;

select * from jde_run_batch_summary;
select * from jde_run_batch_monthly;
select * from jde_run_batch_daily;

select sequence#,
       to_char(completion_time, 'YYYY-MM-DD HH24:MI') completion_time,
       inst_id,
       thread#,
       mins
  from standby_completion_time_detail a order by 1 desc;

select * from standby_completion_time order by 1 desc;

select * from dba_tables where tablespace_name='SYSAUX' and owner in
(select username from dba_users where oracle_maintained!='Y');

select a.*
  from dba_tables a,
       dba_users b
 where a.owner=b.username
   and a.tablespace_name != b.default_tablespace
   and b.oracle_maintained='N';

select * from dba_indexes where owner='PRODDTA' and tablespace_name != 'PRODDTAI';
select * from dba_tables where owner='PRODDTA' and tablespace_name != 'PRODDTAT';

select * from gv$instance;
select * from gv$database;
select * from instance_uptime;

select * from gv$option where parameter = 'Unified Auditing';

select segment_name, status,tablespace_name from dba_rollback_segs;

select * from tsinfo order by 6 desc;
select * from tsinfo where free_gb < 7 and can_extend_gb < 7 order by 6 desc;
select count(*), status, encrypted from dba_tablespaces group by status, encrypted;
select * from dba_tablespaces where status='OFFLINE';
select * from  dba_encrypted_columns;

select * from obj_size_data order by oct desc;

select round(sum(jun)/1024, 1) jun, 
       round(sum(jul)/1024, 1) jul, 
       round(sum(aug)/1024, 1) aug, 
       round(sum(sep)/1024, 1) sep,
       round(sum(oct)/1024, 1) oct
  from obj_size_data;

-- Can be used to spot events, estaimte amount of change going on in the database. 
select * from archive_log_dist order by 1 desc;

select * from flash_recovery_area_space;
select * from asm_space;
select * from v$asm_disk where name is null;

select * from alert_table where closed is not null order by closed desc;
select * from alert_table where closed is null order by opened desc;
delete from alert_table;

declare
  l_warning  varchar2(2) := '97';
  l_critical varchar2(2) := '98';
begin
    dbms_server_alert.set_threshold(
      metrics_id              => dbms_server_alert.tablespace_pct_full,
      warning_operator        => dbms_server_alert.operator_ge,
      warning_value           => l_warning,
      critical_operator       => dbms_server_alert.operator_ge,
      critical_value          => l_critical,
      observation_period      => 1,
      consecutive_occurrences => 1,
      instance_name           => null,
      object_type             => dbms_server_alert.object_type_tablespace,
      object_name             => null);
end;
/

select b.spid processid,
       a.*
  from gv$session a,
       gv$process b
 where a.paddr=b.addr
   and a.inst_id=b.inst_id
   and a.status='ACTIVE' 
   and a.type != 'BACKGROUND' 
   and a.module not in ('XStream') 
   and a.last_call_et > 600;

select * from gv$sql where sql_id='5j6hhczpfgv51';

select * from log_table order by 2 desc;
delete from log_table;
    
select * from blocked_sessions;
select * from blocked_sessions_hist order by insert_time desc;
delete from blocked_sessions_hist where insert_time < systimestamp-31;

select * from sensor_table order by last_time desc;
select count(*), sensor_id, trunc(created) from sensor_hist group by sensor_id, trunc(created) order by 3 desc;
select * from sensor_hist where sensor_id=1 order by created desc;

select * from sql_log_hourly_stat order by 1 desc, 2 desc;
select * from sql_log_weekly_stat order by 1 desc;
select * from sql_log_monthly_stat order by 1 desc;

select substr(sql_text, 1, 10) sql_text,
       force_matching_signature,
       datetime,
       sum(update_count) update_count,
       sum(elapsed_seconds) elapsed_seconds,
       sum(cpu_seconds) cpu_seconds,
       sum(user_io_wait_secs) user_io_wait_secs,
       round(avg(elap_secs_per_exe), 1) elap_secs_per_exe,
       sum(secs_0_1) secs_0_1,
       sum(secs_2_5) secs_2_5,
       sum(secs_6_10) secs_6_10,
       sum(secs_11_60) secs_11_60,
       sum(secs_61_plus) secs_61_plus,
       sum(rows_processed) rows_processed,
       service,
       module,
       action,
       round(avg(elapsed_seconds_ptile), 1) elapsed_seconds_ptile,
       round(avg(elap_secs_per_exe_ptile), 1) elap_secs_per_exe_ptile,
       round(avg(executions_ptile), 1) executions_ptile,
       round(avg(elap_secs_per_exe_med), 1) elap_secs_per_exe_med,
       round(avg(elap_secs_per_exe_avg), 1) elap_secs_per_exe_avg
  from sql_log
 group
    by substr(sql_text, 1, 10),
       force_matching_signature,
       datetime,
       service,
       module,
       action
having sum(elapsed_seconds) > 60
 order
    by 3 desc, 5 desc;
    
select sql_text,
       round(sum(elapsed_seconds/60/60), 1) total_elap_hrs,
       sum(executions) total_executes, 
       round(sum(elapsed_seconds)/sum(executions), 2) secs_per_exe
  from sql_log
 where datetime>=sysdate-8/24
 group
    by sql_text
 order by 2 desc;

-- buftvjq95d6ak Federal (bad plan, went to .5s/exe)

select * from (
select cur.sql_id,
       cur_sum_elap_mins,
       found_in_hr_count,
       cur_avg_elap_mins_per_hr,
       hist_avg_elap_mins_per_hr,
       cur_avg_elap_mins_per_hr-hist_avg_elap_mins_per_hr avg_elap_mins_per_hr_delta,
       cur_avg_exe_per_hr,
       hist_avg_exe_per_hr,
       cur_avg_exe_per_hr-hist_avg_exe_per_hr avg_exe_per_hr_delta,
       cur_avg_elap_secs_per_exe,
       hist_avg_elap_secs_per_exe,
       cur_avg_elap_secs_per_exe-hist_avg_elap_secs_per_exe avg_elap_secs_per_exe_delta
  from (
    select sql_id,
           round(avg(elapsed_seconds/60)) cur_avg_elap_mins_per_hr,
           round(avg(executions)) cur_avg_exe_per_hr,
           round(sum(elapsed_seconds)/60) cur_sum_elap_mins,
           round(avg(elap_secs_per_exe), 2) cur_avg_elap_secs_per_exe,
           count(*) found_in_hr_count
      from sql_log
     where update_time between sysdate-14 and sysdate
     group
        by sql_id) cur,  
    (select sql_id,
           round(avg(elapsed_seconds/60)) hist_avg_elap_mins_per_hr,
           round(avg(executions)) hist_avg_exe_per_hr,
           round(avg(elap_secs_per_exe), 2) hist_avg_elap_secs_per_exe
      from sql_log
     where update_time between sysdate-60 and sysdate-15
     group
        by sql_id) hist
 where cur.sql_id=hist.sql_id
) where avg_elap_mins_per_hr_delta > 0 and avg_elap_secs_per_exe_delta > 1 order by 2 desc;

select * from sql_log where sql_id='b6usrg82hwsa3' order by update_time desc;
select * from sql_log_sql_id_hourly_stat where sql_id='b6usrg82hwsa3' order by 3 desc;
select * from sql_log_sql_id_weekly_stat where sql_id='b6usrg82hwsa3';

set lines 140
set pages 300
select 'exec rdsadmin.rdsadmin_util.kill('||sid||','||serial#||','||'''IMMEDIATE'');' from (
select * from v$session where machine like '%KS5UNEF6');

-- https://jonathanlewis.wordpress.com/2014/03/03/flashback-fail/
select count(*) from sys.smon_scn_time ;

-- Looking for users who's accounts should be locked.
select * from dba_users where username like '%TORF%' or username like '%JENK%';

alter user torf account lock;

SELECT * FROM dba_services;

-- Let's me know when tools were last updated.
select created from dba_objects where object_name='TEST_TABLE';

-- What objects have been created in the last N days.
select * from dba_objects where created >= sysdate-30 order by created desc;

-- Looking for new large tables in the database.
select * from obj_size_data where start_date >= sysdate-90 order by last_size desc;

select * from obj_size_data where segment_name like '%PERF%' or segment_name like '%STAT%' order by last_size desc;

-- Looking for large objects that maybe backup tables.
select * from obj_size_data where jul+aug+sep+oct=0 and segment_type='TABLE' order by last_size desc;

-- Looking for invalid objects.
select * from dba_objects where status != 'VALID' order by created desc;

-- Tables created by hour/date. Can easily spot refreshes and other events.
select * from create_table_dist order by 1 desc;

-- Great Dane - 500 plus tables created on this date.
select * from dba_objects where to_char(created, 'YYYYMMDD') = '20230303';

select * from v$parameter 
 where name like '%compat%' 
    or name like '%spfile%' 
    or name like '%cpu_count%'
    or name like 'statistics_level'
    or name like '%dest%'
    or name like '%memory%'
    or name like '%sga%'
    or name like '%_size' order by name;

select * from dba_autotask_client order by 1;

select * from dba_autotask_task;

select client_name, 
       task_name, 
       round(secs_between_timestamps(sysdate, last_good_date)/60/60/24, 2) last_good_date_in_days 
  from dba_autotask_task
 order
    by 3;

select * from v$datafile where status not in ('ONLINE', 'SYSTEM');

select name, scn, time, guarantee_flashback_database from v$restore_point;

select sys_context('userenv', 'con_name') as current_pdb from dual;

select * from recycle_bin_info;

select * from active_sorts order by 4 desc;
select * from large_sorts;
select * from large_sort_hist;
select * from alert__sort_space;
select * from alert__large_sorts;
select * from sort_info;
select * from v$parameter where name like '%sort%';
select * from v$parameter where name like '%pga_ag%';
select * from dba_temp_files where tablespace_name = 'TEMP';
select * from asm_space;
alter tablespace TEMP add tempfile '+DATA' size 34359721984 autoextend off;
alter database tempfile '+DATA/PRDCDB1/650CA449A619EEB4E0532746010A1A49/TEMPFILE/temp.337.1155979843' autoextend on maxsize 34358689792;
alter database tempfile '+DATA/PRDCDB1/650CA449A619EEB4E0532746010A1A49/TEMPFILE/temp.337.1155979843' resize 34359721984;

-- PURGE DBA_RECYCLEBIN;

select * from rman_status order by start_time desc;

select * from rman_backup_job_details order by start_time desc;

select * from tsinfo order by 6 desc;

select * from tsinfo where free_gb < 7 and can_extend_gb < 7 order by 6 desc;

select round(a.bytes/1024/1024/1024) gb, round(a.maxbytes/1024/1024/1024) maxgb, a.file_name from dba_data_files a 
 where tablespace_name='SYSAUX';

select to_gb(a.bytes) gb, to_gb(a.maxbytes) maxgb, a.* from dba_data_files a 
 where tablespace_name='SYSTEM' order by get_file_name(file_name);
 
select sum(jun), sum(jul) from obj_size_data where tablespace_name='SVM920T';

alter tablespace SYSAUX add datafile '+DATAC1' size 5g;

define f='+DATAC1/DJDEDB12_TORNTO/DATAFILE/sysaux.1174.1154185211';
alter database datafile '&f' autoextend on maxsize 34358689792;
alter database datafile '&f' resize 10g;

select sum(jun), sum(jul) from obj_size_data where tablespace_name='SVM920T';

alter database datafile '/u10/oradata/jdeprd/svm920t03.dbf' autoextend on maxsize 34358689792;
alter database datafile '/u02/oradata/pcntdb01/users01.dbf' resize 5g;


select * from gv$archive_dest where destination is not null;

select * from gv$archive_dest_status where gap_status is not null;

select sum(objects_gb), sum(datafile_gb), sum(can_extend_gb), sum(gb_per_day)*365 from tsinfo;


select * from v$asm_operation;

set lines 140
set pages 1000

column datetime format a25
column mon format 9999 trunc
column tue format 9999 trunc
column wed format 9999 trunc
column thu format 9999 trunc
column fri format 9999 trunc
column sat format 9999 trunc
column sun format 9999 trunc
col sql_id format a20
col sql_text format a40 trunc

prompt "ALL SQL Elapsed Time (Hours Per Day)"

select datetime,
       sum(decode(day_of_week, 'MON', x, 0)) mon,
       sum(decode(day_of_week, 'TUE', x, 0)) tue,
       sum(decode(day_of_week, 'WED', x, 0)) wed,
       sum(decode(day_of_week, 'THU', x, 0)) thu,
       sum(decode(day_of_week, 'FRI', x, 0)) fri,
       sum(decode(day_of_week, 'SAT', x, 0)) sat,
       sum(decode(day_of_week, 'SUN', x, 0)) sun
  from (
select trunc(datetime, 'iw') datetime,
       to_char(datetime, 'DY') day_of_week,
       round(sum(elapsed_seconds/60/60)) x
  from sql_log 
 where datetime >= trunc(sysdate-14)
 group
    by trunc(datetime, 'iw'),
       to_char(datetime, 'DY')
       )
 group
    by datetime
 order
    by 1 desc;

prompt "SQL ID Elapsed Time (Hours Per Day)"

select datetime,
       sql_id,
       sql_text,
       round(sum(decode(day_of_week, 'MON', x, 0)), 1) mon,
       round(sum(decode(day_of_week, 'TUE', x, 0)), 1) tue,
       round(sum(decode(day_of_week, 'WED', x, 0)), 1) wed,
       round(sum(decode(day_of_week, 'THU', x, 0)), 1) thu,
       round(sum(decode(day_of_week, 'FRI', x, 0)), 1) fri,
       round(sum(decode(day_of_week, 'SAT', x, 0)), 1) sat,
       round(sum(decode(day_of_week, 'SUN', x, 0)), 1) sun,
       round(sum(x), 1) ttl
  from (
select trunc(datetime, 'iw') datetime,
       to_char(datetime, 'DY') day_of_week,
       sql_id,
       sql_text,
       round(sum(elapsed_seconds/60/60), 1) x
  from sql_log 
 where datetime >= trunc(sysdate-4)
 group
    by trunc(datetime, 'iw'),
       to_char(datetime, 'DY'),
       sql_id,
       sql_text
       )
 group
    by datetime,
       sql_id,
       sql_text
having sum(x) > 1
 order
    by sum(x) desc;
    
select distinct stat_group from stat_table;

select round(decode(sep, 0, 0, dec/sep*100)) pct_of_sep, a.*    from stat_table a
 where -- hh24_avg > ref_val
       dec>nov and nov>oct and oct>sep and stat_group in ('database_stats', 'database_wait_time')
 order
    by -- decode(ref_val, 0, 0, ddd_avg/ref_val) + decode(ref_val, 0, 0, hh24_avg/ref_val) desc;
       1 desc;

select * from stat_table where stat_group='database_stats' 
  and tags like '%[!]%' 
  and (above_ref_mi > 0 or ddd_above_ref_hrs > 0)
   order by decode(2, 1, stat_value, above_ref_mi) desc;

select * from stat_table where stat_group='database_wait_time' 
   and tags not like '%[Idle]%'
   and (above_ref_mi > 0 or ddd_above_ref_hrs > 0)
   order by decode(2, 1, stat_value, above_ref_mi) desc;
   
select * from stat_table where stat_group='sga_stats'
   and (above_ref_mi > 0 or ddd_above_ref_hrs > 0)
   order by decode(2, 1, stat_value, above_ref_mi) desc;
   
select * from stat_table where stat_group='table_size'
   -- and (above_ref_mi > 0 or ddd_above_ref_hrs > 0)
   order by decode(1, 1, stat_value, above_ref_mi) desc;

select * from stat_table where stat_group like 'tempfile%' 
 order by stat_value desc;

select * from stat_table where stat_group like 'datafile%' order by stat_value desc;

select * from stat_table where stat_group like 'waitstat%'
  order by decode(2, 1, stat_value, above_ref_mi) desc;

select * from stat_table where stat_group in ('meta', 'database', 'oracle_locking', 'scheduled_jobs', 'oracle_sessions', 'alerts', 'asm') 
  order by decode(2, 1, stat_value, above_ref_mi) desc;

-- Disable SQL Tuning Advisor
-- 'ORA-38153 Software edition is incompatible with SQL plan management' in 18.3 Standard Edition (Doc ID 2448865.1)
begin
  dbms_auto_task_admin.disable (
    client_name => 'sql tuning advisor'
,   operation   => null
,   window_name => null
);
end;
/

select to_char(sysdate, 'HH24') from dual;

select sql_text,
       round(sum(tim0)/60, 0) tim0,
       round(sum(tim1)/60, 1) tim1,
       round(sum(tim2)/60, 1) tim2,
       round(sum(tim3)/60, 1) tim3,
       round(sum(tim4)/60, 1) tim4,
       round(sum(tim5)/60, 1) tim5,
       round(sum(tim6)/60, 1) tim6,
       round(sum(tim7)/60, 1) tim7,
       round(sum(tim8)/60, 1) tim8,
       round(sum(tim9)/60, 1) tim9,
       round(sum(tim10)/60, 1) tim10,
       round(sum(tim11)/60, 1) tim11,
       round(sum(tim12)/60, 1) tim12,
       round(sum(tim13)/60, 1) tim13,
       round(sum(tim14)/60, 1) tim14,
       round(sum(tim15)/60, 1) tim15,
       round(sum(tim16)/60, 1) tim16,
       round(sum(tim17)/60, 1) tim17,
       round(sum(tim18)/60, 1) tim18,
       round(sum(tim19)/60, 1) tim19,
       round(sum(tim20)/60, 1) tim20,
       round(sum(tim21)/60, 1) tim21,
       round(sum(tim22)/60, 1) tim22,
       round(sum(tim23)/60, 1) tim23,
       round(sum(total)/60, 1) total,
       round(avg(avg0), 3) avg0,
       round(avg(avg1), 3) avg1,
       round(avg(avg2), 3) avg2,
       round(avg(avg3), 3) avg3,
       round(avg(avg4), 3) avg4,
       round(avg(avg5), 3) avg5,
       round(avg(avg6), 3) avg6,
       round(avg(avg7), 3) avg7,
       round(avg(avg8), 3) avg8,
       round(avg(avg9), 3) avg9,
       round(avg(avg10), 1) avg10,
       round(avg(avg11), 1) avg11,
       round(avg(avg12), 1) avg12,
       round(avg(avg13), 1) avg13,
       round(avg(avg14), 1) avg14,
       round(avg(avg15), 1) avg15,
       round(avg(avg16), 1) avg16,
       round(avg(avg17), 1) avg17,
       round(avg(avg18), 1) avg18,
       round(avg(avg19), 1) avg19,
       round(avg(avg20), 1) avg20,
       round(avg(avg21), 1) avg21,
       round(avg(avg22), 1) avg22,
       round(avg(avg23), 1) avg23,
       round(sum(exe0/1000), 1) exe0,
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

select sql_text,
       round(sum(tim0)/60/60, 1) tim0,
       round(sum(tim1)/60/60, 1) tim1,
       round(sum(tim2)/60/60, 1) tim2,
       round(sum(tim3)/60/60, 1) tim3,
       round(sum(tim4)/60/60, 1) tim4,
       round(sum(tim5)/60/60, 1) tim5,
       round(sum(tim6)/60/60, 1) tim6,
       round(sum(tim7)/60/60, 1) tim7,
       round(sum(tim8)/60/60, 1) tim8,
       round(sum(total)/60/60, 1) total,
       round(avg(avg0), 1) avg0,
       round(avg(avg1), 1) avg1,
       round(avg(avg2), 1) avg2,
       round(avg(avg3), 1) avg3,
       round(avg(avg4), 1) avg4,
       round(avg(avg5), 1) avg5,
       round(avg(avg6), 1) avg6,
       round(avg(avg7), 1) avg7,
       round(avg(avg8), 1) avg8,
       round(sum(exe0/1000), 1) exe0,
       round(sum(exe1/1000), 1) exe1,
       round(sum(exe2/1000), 1) exe2,
       round(sum(exe3/1000), 1) exe3,
       round(sum(exe4/1000), 1) exe4,
       round(sum(exe5/1000), 1) exe5,
       round(sum(exe6/1000), 1) exe6,
       round(sum(exe7/1000), 1) exe7,
       round(sum(exe8/1000), 1) exe8
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
 where datetime >= trunc(sysdate) - (8)))
 group
    by sql_text
 order by 2 desc;


 select sql_text,
       round(sum(tim1)/60/60, 1) tim1,
       round(sum(tim2)/60/60, 1) tim2,
       round(sum(tim3)/60/60, 1) tim3,
       round(sum(tim4)/60/60, 1) tim4,
       round(sum(tim5)/60/60, 1) tim5,
       round(sum(tim6)/60/60, 1) tim6,
       round(sum(tim7)/60/60, 1) tim7,
       round(sum(tim8)/60/60, 1) tim8,
       round(sum(tim9)/60/60, 1) tim9,
       round(sum(tim10)/60/60, 1) tim10,
       round(sum(tim11)/60/60, 1) tim11,
       round(sum(tim12)/60/60, 1) tim12,
       round(sum(total)/60/60, 1) total,
       round(avg(avg1), 3) avg1,
       round(avg(avg2), 3) avg2,
       round(avg(avg3), 3) avg3,
       round(avg(avg4), 3) avg4,
       round(avg(avg5), 3) avg5,
       round(avg(avg6), 3) avg6,
       round(avg(avg7), 3) avg7,
       round(avg(avg8), 3) avg8,
       round(avg(avg9), 3) avg9,
       round(avg(avg10), 1) avg10,
       round(avg(avg11), 1) avg11,
       round(avg(avg12), 1) avg12,
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
 order by 14 desc;

 select sql_text,
       round(sum(tim0)/60/60, 1) tim0,
       round(sum(tim1)/60/60, 1) tim1,
       round(sum(tim2)/60/60, 1) tim2,
       round(sum(tim3)/60/60, 1) tim3,
       round(sum(tim4)/60/60, 1) tim4,
       round(sum(tim5)/60/60, 1) tim5,
       round(sum(tim6)/60/60, 1) tim6,
       round(sum(tim7)/60/60, 1) tim7,
       round(sum(tim8)/60/60, 1) tim8,
       round(sum(total)/60/60, 1) total,
       round(avg(avg0), 1) avg0,
       round(avg(avg1), 1) avg1,
       round(avg(avg2), 1) avg2,
       round(avg(avg3), 1) avg3,
       round(avg(avg4), 1) avg4,
       round(avg(avg5), 1) avg5,
       round(avg(avg6), 1) avg6,
       round(avg(avg7), 1) avg7,
       round(avg(avg8), 1) avg8,
       round(sum(exe0/1000), 1) exe0,
       round(sum(exe1/1000), 1) exe1,
       round(sum(exe2/1000), 1) exe2,
       round(sum(exe3/1000), 1) exe3,
       round(sum(exe4/1000), 1) exe4,
       round(sum(exe5/1000), 1) exe5,
       round(sum(exe6/1000), 1) exe6,
       round(sum(exe7/1000), 1) exe7,
       round(sum(exe8/1000), 1) exe8
  from (
select substr(sql_text, 1, 22) sql_text,
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
 where datetime >= sysdate - (7*8)))
 group
    by sql_text
 order by 2 desc;

select round(cpu_time/1000000) cpu_sec, 
       round(elapsed_time/1000000) elap_sec, 
       executions, 
       round(user_io_wait_time/1000000) user_io_wait_sec, 
       rows_processed, 
       to_gb(io_interconnect_bytes) io_interconnect_gb, 
       to_gb(physical_read_bytes) phyrd_gb, 
       to_gb(physical_write_bytes) phywrt_gb, 
       sql_text
  from v$sql
 order by 8 desc;

select * from gv$archive_dest where destination is not null;

select * from gv$log_history order by sequence# desc;

select to_char(max(first_time), 'YYYY-MM-DD HH24:MI:SS') first_time,
       to_char(max(next_time), 'YYYY-MM-DD HH24:MI:SS') next_time,
       to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS') now
from gv$archived_log a;

select * from gv$archived_log a order by sequence# desc;

select * from gv$archived_log;

select * from gv$archive_dest_status a where gap_status is not null;

select * from archive_log_dist order by 1 desc;

select count(*) from gv$archived_log where standby_dest='YES' and applied != 'YES';
select * from gv$archive_dest_status where applied_seq# > 0 and gap_status not in ('NO GAP');

select (extract(day from val)*86400)+(extract(hour from val)*3600)+(extract(minute from val)*60)+
       (extract(second from val)) secs,
       name,
       inst_id
  from (
select to_dsinterval(value) val,
      a.* 
      from gv$dataguard_stats a where name in ('transport lag', 'apply lag'));

select to_char(timestamp, 'YYYY-MM-DD HH24:MI:SS') timestamp,
       facility,
       severity,
       dest_id,
       error_code,
       message
  from v$dataguard_status a 
 order
    by timestamp desc;