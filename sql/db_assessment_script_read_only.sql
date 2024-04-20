
spool C:\temp\spool\system_event.csv
with uptime as (
   select /*csv*/ inst_id, 
          round(sysdate-logon_time, 1) days,
          round(sysdate-logon_time, 1)*24 hours,
          round(sysdate-logon_time, 1)*24*60 minutes,
          round(sysdate-logon_time, 1)*24*60*60 seconds
     from gv$session where program like '%(PMON)%')
select a.event|| ' ('||a.wait_class||')' name,
       b.inst_id,
       round(time_waited/100/b.minutes, 2) value,
       'secs/min' info,
       round(a.average_wait/100, 2) average_wait_secs
  from gv$system_event a,
       uptime b
where a.inst_id=b.inst_id
  and a.wait_class not in ('Idle')
order by 3 desc;
spool off

spool C:\temp\spool\sysstat.csv
with uptime as (
   select /*csv*/ inst_id, 
          round(sysdate-logon_time, 1) days,
          round(sysdate-logon_time, 1)*24 hours,
          round(sysdate-logon_time, 1)*24*60 minutes,
          round(sysdate-logon_time, 1)*24*60*60 seconds
     from gv$session where program like '%(PMON)%')
select c.name||' ('||a.statistic#||')' name,
       b.inst_id,
       round(value/b.minutes, 2) value,
       'value/min' info
  from gv$sysstat a,
       uptime b,
       v$statname c
where a.inst_id=b.inst_id
  and a.statistic#=c.statistic#
order by 3 desc;
spool off

spool C:\temp\spool\sql_last_active_7_days.csv
select /*csv*/ substr(sql_text, 1, 60) sql_text,
       inst_id,
       min(last_active_time) min_last_active_time,
       sum(executions) executions,
       round(sum(user_io_wait_time)/1000000/60/60, 2) user_io_wait_hrs,
       service,
       module,
       round(sum(cpu_time)/1000000/60/60, 2) cpu_hrs,
       round(sum(elapsed_time)/1000000/60/60, 2) elapsed_hrs,
       round(sum(physical_read_bytes)/1024/1024/1024, 2) physical_read_gb
  from gv$sql
 where last_active_time >= sysdate-7
 group
    by substr(sql_text, 1, 60),
       inst_id,
       service,
       module
 order 
    by 8 desc;
spool off

spool C:\temp\spool\owner_size.csv
select /*csv*/ owner, round(sum(bytes)/1024/1024/1024, 2) gb from dba_segments group by owner order by 2 desc;
spool off

spool C:\temp\spool\tsinfo.csv
select /*csv*/ tablespace_name, round(sum(bytes)/1024/1024/1024, 2) gb from dba_segments group by tablespace_name order by 2 desc;
spool off

spool C:\temp\spool\table_size.csv
select /*csv*/ owner, segment_name, segment_type, tablespace_name, bytes from dba_segments where bytes > 10*1024*1024*1024 and segment_type not in ('INDEX') order by bytes desc;
spool off

spool C:\temp\spool\sgastat.csv
select /*csv*/ inst_id, pool, name, round(bytes/1024/1024/1024, 2) gb from gv$sgastat where bytes > 128*1024*1024 order by 4 desc;
spool off

spool C:\temp\spool\osstat.csv
with uptime as (
   select /*csv*/ inst_id, 
          round(sysdate-logon_time, 1) days,
          round(sysdate-logon_time, 1)*24 hours,
          round(sysdate-logon_time, 1)*24*60 minutes,
          round(sysdate-logon_time, 1)*24*60*60 seconds
     from gv$session where program like '%(PMON)%')
select a.stat_name name,
       b.inst_id,
       round(value/b.minutes, 2) value,
       'value/min' info,
       a.value raw_value
  from gv$osstat a,
       uptime b
where a.inst_id=b.inst_id;
spool off
  
spool C:\temp\spool\arch_dist.csv
select /*csv*/ to_char(dt, 'YYYY-MM-DD') dt,
sum(decode(hh,0,1,0)) "00",
sum(decode(hh,1,1,0)) "01",
sum(decode(hh,2,1,0)) "02",
sum(decode(hh,3,1,0)) "03",
sum(decode(hh,4,1,0)) "04",
sum(decode(hh,5,1,0)) "05",
sum(decode(hh,6,1,0)) "06",
sum(decode(hh,7,1,0)) "07",
sum(decode(hh,8,1,0)) "08",
sum(decode(hh,9,1,0)) "09",
sum(decode(hh,10,1,0)) "10",
sum(decode(hh,11,1,0)) "11",
sum(decode(hh,12,1,0)) "12",
sum(decode(hh,13,1,0)) "13",
sum(decode(hh,14,1,0)) "14",
sum(decode(hh,15,1,0)) "15",
sum(decode(hh,16,1,0)) "16",
sum(decode(hh,17,1,0)) "17",
sum(decode(hh,18,1,0)) "18",
sum(decode(hh,19,1,0)) "19",
sum(decode(hh,20,1,0)) "20",
sum(decode(hh,21,1,0)) "21",
sum(decode(hh,22,1,0)) "22",
sum(decode(hh,23,1,0)) "23"
from
(
select trunc(first_time) dt,
       to_number(to_char(first_time,'HH24')) hh
  from v$archived_log
 where first_time >= trunc(sysdate) - 60
)
 group 
    by to_char(dt, 'YYYY-MM-DD')
 order by 1 desc
/
spool off

spool C:\temp\spool\resource_limit.csv
select /*csv*/ inst_id, 
       resource_name, 
       current_utilization, 
       max_utilization, 
       to_number(limit_value) limit_value, 
       con_id, 
       decode(trim(limit_value), '0', 0, decode(trim(limit_value), 'UNLIMITED', 0, round(current_utilization/limit_value*100))) current_pct_used
  from gv$resource_limit 
 where trim(limit_value) != 'UNLIMITED'
   and trim(limit_value) not in '0';
spool off
   
spool C:\temp\spool\scheduler.csv
select /*csv*/ to_char(a.log_date, 'YYYY-MM-DD HH24:MI') log_date,
       a.owner,
       a.job_name,
       a.status,
       c.errors
  from dba_scheduler_job_log a,
       (select max(log_id) log_id, owner, job_name
          from dba_scheduler_job_log
         group
            by owner, job_name) b,
       dba_scheduler_job_run_details c
 where a.log_id=b.log_id
   and a.owner=b.owner 
   and a.job_name=b.job_name
   and a.log_date >= sysdate-90
   and a.owner not like 'APEX%'
   and a.owner != 'SYS'
   and a.log_id=c.log_id
 order by a.log_date desc;
spool off

spool C:\temp\spool\size.csv
select /*csv*/ 'Estimated Total Size: '||round((select sum(bytes)/1024/1024/1024 from gv$datafile where inst_id=1 ) + 
(select sum(bytes)/1024/1024/1024 from gv$tempfile where inst_id=1), 1) || ' GB''s' size_info from dual
union all
select 'Total GB associated with datafiles including UNDO: '||round(sum(bytes)/1024/1024/1024,1) x from gv$datafile where inst_id=1
union all
select 'Total GB associated with tempfiles: '||round(sum(bytes)/1024/1024/1024, 1) gb from gv$tempfile where inst_id=1;
spool off

spool C:\temp\spool\asm_info.csv
select /*csv*/
    name                                     group_name
  , sector_size                              sector_size
  , block_size                               block_size
  , allocation_unit_size                     allocation_unit_size
  , state                                    state
  , type                                     type
  , round(total_mb/1024, 1)                  total_gb
  , round((total_mb - free_mb)/1024, 1)      used_gb
  , round((1- (free_mb / total_mb))*100)     pct_used
from
    gv$asm_diskgroup
/
spool off