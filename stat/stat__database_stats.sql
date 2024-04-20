create or replace view stat__database_stats as
select 'uptime_days ('||inst_id||')' stat_name,
       'database' stat_group,
       'value' stat_type,
       round(sysdate-startup_time, 1) value,
       null tags,
       null value_convert,
       null stat_label
  from gv$instance;