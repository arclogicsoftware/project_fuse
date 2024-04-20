

delete from config_table where name='alert__long_running_sqls_hours';

begin
   app_config.add_param_num(p_name=>'alert__long_active_sql_mins', p_num=>240);
end;
/

exec drop_view('alert__long_running_sqls');

create or replace view alert__long_active_sql as
select 'warning' alert_level,
       'long_active_sql_'||sql_id alert_name,
       'rows='||count(*)||' hours='||round(sum(last_call_et)/60/60, 1) alert_info,
       'database' alert_type
   from gv$session 
 where status='ACTIVE' 
   and type != 'BACKGROUND' 
   and module not in ('XStream', 'Data Pump Worker', 'Data Pump Master')
   and last_call_et > 0
 having sum(last_call_et) > 60*app_config.get_param_num('alert__long_active_sql_mins', 240)
 group
    by 'warning',
       'long_active_sql_'||sql_id,
       'database',
       0;
