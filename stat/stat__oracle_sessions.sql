create or replace view stat__oracle_sessions as
select 'module_max_last_call_et_secs ('||module||')' stat_name,
       'oracle_sessions' stat_group,
       'value' stat_type,
       round(max(last_call_et)) value,
       null tags,
       null value_convert,
       null stat_label
  from gv$session
 where status='ACTIVE'
   and type != 'BACKGROUND'
 group
    by module
union all
select 'sessions_active_avg_last_call_et_secs' stat_name,
       'oracle_sessions' stat_group,
       'value' stat_type,
       round(avg(last_call_et)) value,
       null tags,
       null value_convert,
       null stat_label
  from gv$session
 where status='ACTIVE'
   and type != 'BACKGROUND'
union all
select 'sessions_active_max_last_call_et_secs' stat_name,
       'oracle_sessions' stat_group,
       'value' stat_type,
       round(max(last_call_et)) value,
       null tags,
       null value_convert,
       null stat_label
  from gv$session
 where status='ACTIVE'
   and type != 'BACKGROUND'
union all
select 'sessions' stat_name,
       'oracle_sessions' stat_group,
       'value' stat_type,
       count(*) value,
       null tags,
       null value_convert,
       null stat_label
  from gv$session
union all
select 'sessions_type_'||lower(type) stat_name,
       'oracle_sessions' stat_group,
       'value' stat_type,
       count(*) value,
       null tags,
       null value_convert,
       null stat_label
  from gv$session
 group
    by type
union all
select 'sessions_osuser_'||lower(osuser) stat_name,
       'oracle_sessions' stat_group,
       'value' stat_type,
       count(*) value,
       null tags,
       null value_convert,
       null stat_label
  from gv$session
 group
    by osuser
union all
select 'sessions_module_'||lower(nvl(module, 'NULL')) stat_name,
       'oracle_sessions' stat_group,
       'value' stat_type,
       count(*) value,
       null tags,
       null value_convert,
       null stat_label
  from gv$session
 group
    by nvl(module, 'NULL')
union all
select 'sessions_username_'||lower(nvl(username, 'NULL')) stat_name,
       'oracle_sessions' stat_group,
       'value' stat_type,
       count(*) value,
       null tags,
       null value_convert,
       null stat_label
  from gv$session
 group
    by nvl(username, 'NULL')
union all
select 'sessions_status_'||lower(status) stat_name,
       'oracle_sessions' stat_group,
       'value' stat_type,
       count(*) value,
       null tags,
       null value_convert,
       null stat_label
  from gv$session
 group
    by status;
