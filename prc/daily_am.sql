create or replace procedure daily_am as 
begin
   update alert_table set ready_notify=1 where closed is null;
   delete from blocked_sessions_hist where insert_time > systimestamp-31;
   delete from stat_table where stat_group='oracle_sessions' and value_time < systimestamp-7;
   
   -- -------------------------------------------------------------------------
   -- PURGE DATA
   -- -------------------------------------------------------------------------

   -- Sensor Purge
   delete from sensor_hist 
    where sensor_id=(select sensor_id from sensor_table where sensor_view='sensor__session_user_programs')
      and created < systimestamp-90;
   delete from sensor_hist where created < sysdate - app_config.get_param_num('sensor_purge_days', 365);
   delete from sensor_hist 
    where sensor_id=(select sensor_id from sensor_table where sensor_view='sensor__session_user_programs')
      and created < systimestamp-90;

   -- Alert Purge
   delete from alert_table where opened < systimestamp - interval '1' year;

   commit;
end;
/