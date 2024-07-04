set pagesize 100
set lines 140
set feed off
set trimout on

col status format a8 trunc
col alert_level format a10 trunc heading "LEVEL"
col alert_name format a30 trunc heading "NAME"
col alert_type format a25 trunc heading "TYPE"
col hrs_open format 9999.9 trunc heading "HRS OPEN"
col alert_info format a45 trunc heading "INFO"

select status,
       alert_level,
       alert_name,
       alert_type,
       hrs_open,
       alert_info
 from alerts_ready_notify
 order by to_number(hrs_open);

set lines 140
set pages 100
set feed off
col log_time format a18
col log_type format a12
col log_text format a90

select to_char(log_time, 'YYYY-MM-DD HH24:MI') log_time,
       log_type,
       log_text
  from log_table
 where ready_notify=1
 order
    by log_time;

update log_table set ready_notify=0 where ready_notify=1;

commit;

col lock_level format 99999
col username format a20 trunc
col osuser format a20 trunc
col processid format 99999
col clientpid format a20
col inst_id format 99999
col sid format 99999
col serial# format 999999
col machine format a20

select
level lock_level,
       --blocking_session_status,
       -- LPAD(' ', (level-1)*2, ' ') || nvl(s.username, '(oracle)') as username,
             nvl(s.username, '(oracle)') as username,
       s.osuser,
       p.spid processid,
       s.process clientpid,
       s.inst_id,
       s.sid,
       s.serial#,
       s.sql_id,
       s.machine
FROM   gv$session s,
       gv$process p
WHERE s.paddr = p.addr
--and s.inst_id = p.inst_id
and wait_time_micro > (1000000 * 60 *  1 )
and (select count(*) 
       from alert_table 
      where ready_notify=1
        and alert_name='blocked_sessions' and closed is null) >= 1
and
(level > 1
or     exists (select 1
               from   gv$session s2
               where  s2.blocking_session  = s.sid
               and    s2.blocking_instance = s.inst_id))
connect by prior s.sid = s.blocking_session
start with s.blocking_session is null order by 1;


col block format a12
col inst_id format 99999
col sid format 99999
col serial# format 999999
col username format a20 trunc
col machine format a20 trunc
col program format a20 trunc
col last_call_et format 99999

select block,
       inst_id,
       sid,
       serial#,
       username,
       machine,
       program,
       last_call_et
  from blocked_sessions
 where last_call_et > 300
   and (select count(*) from alert_table 
         where ready_notify=1
           and alert_name='blocked_sessions' and closed is null) >= 1;

update alert_table
   set notify_count=notify_count+1,
       ready_notify=0,
       last_notify=systimestamp
 where ready_notify=1;

commit;