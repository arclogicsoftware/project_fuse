create or replace view long_active_calls as 
select processid, sid, serial#, username, machine, sql_id, round(last_call_et/60/60, 1) call_running_for_hours, module, logon_time from (
select b.spid processid,
       a.*
  from gv$session a,
       gv$process b
 where a.paddr=b.addr
   and a.inst_id=b.inst_id
   and a.status='ACTIVE' 
   and a.type != 'BACKGROUND' 
   and a.module not in ('XStream') 
   and a.last_call_et > 600);