

create or replace procedure monitor_blocked_sessions is
   n number;
   v_ready_notify number := 0;
begin
    
   -- Get count of records matching alert condition.
   select count(*) into n from alert_table 
    where alert_name like '%blocked_session%'
      and closed is null;

   if n > 0 then 
      insert into blocked_sessions_hist (
         block,
         inst_id,
         sid,
         serial#,
         paddr,
         spid,
         username,
         process,
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
         event,
         ready_notify) (select
         block,
         inst_id,
         sid,
         serial#,
         paddr,
         spid,
         username,
         process,
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
         event,
         v_ready_notify
         from blocked_sessions);
   end if;

   commit;

end;
/

