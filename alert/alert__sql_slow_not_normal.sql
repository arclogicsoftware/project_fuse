
begin
   app_config.add_param_num(p_name=>'alert__sql_slow_not_normal_elap_mins', p_num=>20);
end;
/

 create or replace view alert__sql_slow_not_normal as
    select 'warning' alert_level,
           'long_running_sql_'||lower(sql_id) alert_name,
           'elapsed_hours='||round(elapsed_seconds/60/60, 1) alert_info,
           'database' alert_type,
           0 alert_delay
     from (select sql_id, 
                  sum(elapsed_seconds) elapsed_seconds
             from sql_log 
            where fms_elapsed_seconds > 60 * app_config.get_param_num('alert__sql_slow_not_normal_elap_mins', 20)
              and elapsed_seconds_ptile >= .9
              and update_time >= sysdate-(3/24)
              and sql_id not in ('b6usrg82hwsa3')
            group
               by sql_id
           having count(*) > 1);

 
 