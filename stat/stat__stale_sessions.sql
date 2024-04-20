create or replace view stat__stale_sessions as
select 'stale_sessions_count' stat_name,
       'database' stat_group,
       'value' stat_type,
       count(*) value,
       null tags,
       null value_convert,
       null stat_label
  from gv$session
 where last_call_et > (86400*7)
   and program not like 'oracle@%';