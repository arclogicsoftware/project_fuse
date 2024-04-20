create or replace view blocked_sessions as
select 'IS BLOCKED' block, 
       systimestamp insert_time,
       inst_id, 
       sid, 
       serial#, 
       paddr,
       username, 
       process, 
       (select spid from gv$process b where a.paddr=b.addr and a.inst_id=b.inst_id) spid,
       machine, 
       state, 
       program, 
       terminal, 
       sql_id, 
       prev_sql_id, 
       module, 
       last_call_et, 
       blocking_instance, 
       blocking_session, 
       event
  from gv$session a 
 where blocking_session_status='VALID' 
       and type != 'BACKGROUND'
       and last_call_et > 0
union all
select 'IS BLOCKING' block, 
       systimestamp insert_time,
       a.inst_id, 
       a.sid, 
       a.serial#, 
       a.paddr,
       a.username, 
       a.process, 
       (select spid from gv$process b where a.paddr=b.addr and a.inst_id=b.inst_id) spid,
       a.machine, 
       a.state, 
       a.program, 
       a.terminal, 
       a.sql_id, 
       a.prev_sql_id, 
       a.module, 
       a.last_call_et, 
       a.blocking_instance, 
       a.blocking_session, 
       a.event
  from gv$session a, 
       (select distinct blocking_session, blocking_instance
          from gv$session 
         where blocking_session_status='VALID' 
           and type != 'BACKGROUND'
           and last_call_et > 0) b
 where a.sid=b.blocking_session
   and a.inst_id=b.blocking_instance
   and a.type != 'BACKGROUND';