begin
   app_config.add_param_num(p_name=>'blocked_sessions_alert_mins', p_num=>5);
end;
/

create or replace view alert__blocked_sessions as 
select 'warning' alert_level,
       'database' alert_type,
       'blocked_sessions' alert_name,
       'IS BLOCKED='||value alert_info
  from
       (
		select count(*) value
		  from blocked_sessions
		 where block='IS BLOCKED' 
		   and last_call_et > 60*app_config.get_param_num('blocked_sessions_alert_mins', 5)
		having count(*) > 0
       );
