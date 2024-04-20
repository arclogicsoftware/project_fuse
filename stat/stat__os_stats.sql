create or replace view stat__os_stats as
select stat_name|| ' ('||inst_id||')' stat_name,
       'database' stat_group,
       'value' stat_type,
       round(value, 1) value,
       null tags,
       null value_convert,
       null stat_label
  from gv$osstat where stat_name like 'NUM%'
    or stat_name in ('LOAD')
    or stat_name like 'TCP_%'
    or stat_name like 'GLOBAL_%'
union all
select stat_name|| ' ('||inst_id||')' stat_name,
       'database' stat_group,
       'rate' stat_type,
       value value,
       null tags,
       '/100' value_convert,
       'seconds/sec' stat_label
  from gv$osstat where stat_name not like 'NUM%'
    and stat_name not in ('LOAD')
    and stat_name not like 'TCP_%'
    and stat_name not like 'GLOBAL_%'
    and stat_name like '%_TIME'
union all
select stat_name|| ' ('||inst_id||')' stat_name,
       'database' stat_group,
       'value' stat_type,
       value value,
       null tags,
       '/1024' value_convert,
       'mb' stat_label
  from gv$osstat where stat_name not like 'NUM%'
    and stat_name not in ('LOAD')
    and stat_name not like 'TCP_%'
    and stat_name not like 'GLOBAL_%'
    and stat_name not like '%_TIME'
    and stat_name like '%_BYTES';