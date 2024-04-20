begin
   app_config.add_param_num(p_name=>'alert__sort_space_cur_pct_in_use', p_num=>85);
end;
/

create or replace view alert__sort_space as
 select 'warning' alert_level,
        upper(tablespace_name||'_cur_pct_in_use') alert_name,
        'cur_pct_in_use='||cur_pct_in_use||', cur_sessions_in_use='||cur_sessions_in_use alert_info,
        'database' alert_type
   from sort_info 
  where size_in_gb > 1
    and cur_pct_in_use >= app_config.get_param_num('alert__sort_space_cur_pct_in_use', 85);