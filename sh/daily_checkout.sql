
set lines 140
set pages 100
set feed off

col created format a15 heading "G-DATE"
col db_name format a15

prompt
prompt ====================================================
prompt DATABASE
prompt ====================================================

select created,
       sys_context('userenv', 'db_name') db_name 
  from dba_objects 
 where object_name='TEST_TABLE';

col inst_id format 9999
col uptime format a40
col start_time format a40

prompt
prompt [UPTIME]

select * from instance_uptime;

prompt
prompt [SGA INFO]

col inst_id format 999
col pool format a25
col name format a25
col gb format 99999.9

select * from sga_info order by gb desc;

prompt
prompt [ALERT HISTORY LAST 24 HOURS]

col alert_level format a14
col alert_name format a20 trunc
col alert_info format a30 trunc
col alert_type format a14
col opened format a18
col closed format a18

select alert_level,
       alert_name,
       alert_info,
       alert_type,
       to_char(opened, 'YYYY-MM-DD HH24:MI') opened,
       to_char(closed, 'YYYY-MM-DD HH24:MI') closed
  from alert_table 
 where opened >= sysdate-1
    or closed is null
 order 
    by 5;

prompt
prompt [ASM SPACE]

col group_name format a15 
col total_gb format 999999
col used_gb format 999999
col free_gb format 999999
col pct_used format 999

select group_name, total_gb, used_gb, total_gb-used_gb free_gb, pct_used from asm_space;

column tablespace_name format a20
column objects_gb format 999,999
column free_gb format 999,999
column pct_full format 999
column gb_per_day format 999.99
column estimated_days_remaining format 99999
column autoextend_pct_full format 999
column max_days_remaining format 99999

prompt
prompt [TABLESPACE INFO]

select tablespace_name,
       objects_gb,
       free_gb,
       pct_full,
       gb_per_day,
       estimated_days_remaining,
       autoextend_pct_full,
       max_days_remaining
  from tsinfo
 where (gb_per_day != 0 
    or estimated_days_remaining < 30
    or max_days_remaining < 30
    or pct_full > 90)
   and objects_gb > 0
 order
    by 5 desc;

col pct_full_reclaimable format 999
col pct_full format 999
col space_limit_gb format 999,999
col space_used_gb format 999,999
col number_of_files format 9999
col name format a30 trunc
col con_id format 999

prompt
prompt [FLASH RECOVERY SPACE]

select * from flash_recovery_area_space;

prompt
prompt [AVG SQL ELAPSED HOURS PER HOUR]

col week_of format a15
col avg_sql_elap_hr_per_hr format 999.9
set lines 140
set pages 100

select to_char(sql_date, 'YYYY-MM-DD') week_of,
       round(avg_sql_elap_mins/60, 1) avg_sql_elap_hr_per_hr
  from sql_log_weekly_stat
 where sql_date >= sysdate-90
 order by 1;

prompt
prompt [LOG TABLE HISTORY LAST 24 HOURS]

col log_time format a18
col log_type format a10 trunc
col log_text format a90 trunc

select to_char(log_time, 'YYYY-MM-DD HH24:MI') log_time,
       log_type,
       log_text
  from log_table
 where log_time>=sysdate-1
 order
    by 1;

set lines 120
set pages 100
col rec_count format 999999999
col event_timestamp format a20

prompt
prompt [UNIFIED AUDIT TRAIL RECORD COUNT]

select count(*) rec_count, trunc(event_timestamp) event_timestamp 
from unified_audit_trail
where event_timestamp >= current_timestamp - interval '1' month
 group by trunc(event_timestamp) order by 2 desc;