create or replace procedure daily_am as 
begin
   update alert_table set ready_notify=1 where closed is null;
   delete from blocked_sessions_hist where insert_time > systimestamp-31;
   sensor_purge;
   delete from stat_table where stat_group='oracle_sessions' and value_time < systimestamp-7;
   commit;
end;
/