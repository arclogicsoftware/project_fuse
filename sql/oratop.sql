prompt
prompt oratop.sql
prompt =================================================================
prompt

set pages 40
set lines 120
set feedback off heading off term off

drop table tmp_sesstat_previous;
rename tmp_sesstat_current to tmp_sesstat_previous;

create table tmp_sesstat_current as (
   select a.*, 
          b.serial#, 
          sysdate time_stamp ,
          cast (null as varchar(128)) name,
          cast (null as varchar(128)) class
     from gv$sesstat a, 
          gv$session b
    where a.inst_id=b.inst_id
      and a.value > 0
      and a.sid=b.sid
      and b.type != 'BACKGROUND')
/

update tmp_sesstat_current a
   set name=(select name from v$statname b where a.statistic#=b.statistic#);
   
update tmp_sesstat_current a 
   set class='!' 
 where name in ('user commits', 'user rollbacks', 'session logical reads',
    'physical reads', 'physical writes', 'parse count (hard)',
    'sorts (disk)', 'sorts (rows)', 'bytes sent via SQL*Net to client',
    'bytes received via SQL*Net from client', 'CPU used by this session',
    'redo blocks written', 'table scans (long tables)', 'table scan rows gotten',
    'free buffer requested', 'execute count', 'session pga memory',
    'session uga memory', 'user I/O wait time', 'DB time');
   
drop table tmp_session_event_previous;
rename tmp_session_event_current to tmp_session_event_previous;

create table tmp_session_event_current as (
   select a.*, 
          b.serial#, 
          sysdate time_stamp 
     from gv$session_event a, 
          gv$session b
    where a.sid=b.sid
      and a.inst_id=b.inst_id
      and a.wait_class <> 'Idle')
/
        
set feedback off heading on term on

col sid format a12 heading "SID (INST)"
col name format a40 trunc
col event format a40 trunc

select a.sid||' ('||a.inst_id||')' sid,
       a.event,
       round((a.time_waited-b.time_waited)/100,1) secs_waited,
       round((a.total_waits-b.total_waits)/((a.time_stamp-b.time_stamp)*1440),1) waits_per_min,
       round(a.time_waited/100/60,1) total_secs_waited
  from tmp_session_event_current a, 
       tmp_session_event_previous b
 where a.sid=b.sid
   and a.event=b.event
   and a.serial#=b.serial#
   and a.inst_id=b.inst_id
   and (a.time_waited-b.time_waited)/100 > .1
 order
    by 3, 1;

create or replace view tmp_oratop as
select sid, inst_id, name, serial#, rate_per_sec, delta_value,
       rank () over (partition by name order by name, delta_value desc) stat_rank from (
select a.inst_id,
       a.sid,
       a.name,
       a.serial#,
       b.value-a.value delta_value,
       round((b.time_stamp-a.time_stamp)*24*60*60) time_delta,
       case
          when round((b.time_stamp-a.time_stamp)*24*60*60) > 0  
             then round((b.value-a.value)/((b.time_stamp-a.time_stamp)*24*60*60), 2)
          else 
             0
       end rate_per_sec
 from tmp_sesstat_previous a,
      tmp_sesstat_current b
 where a.class='!' 
   and b.class='!'
   and b.value-a.value != 0
   and a.inst_id=b.inst_id 
   and a.sid=b.sid
   and a.serial#=b.serial#
   and a.statistic#=b.statistic#);
   
create or replace view tmp_oratop_avg_stat_rank as
select sid, 
       inst_id, 
       round(avg(stat_rank)) stat_rank
  from tmp_oratop a 
 group by sid, inst_id order by 3 desc;

select * from tmp_oratop order by stat_rank, name, sid;

select * from tmp_oratop_avg_stat_rank order by 3;

select a.*,
       b.*
  from tmp_oratop_avg_stat_rank a,
       gv$session b 
 where a.sid=b.sid 
   and a.inst_id=b.inst_id
   and a.stat_rank <=10 
 order by stat_rank desc;
 
-- select * from gv$sql where sql_id='bn4ttk1898ms4';

set feedback on

