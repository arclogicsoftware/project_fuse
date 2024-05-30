  create or replace view stat__segment_stats as 
  select owner||'.'||object_name||' '||statistic_name||' ('||inst_id||')' stat_name,
       'segment_stats' stat_group,
       'rate' stat_type,
       value,
       null tags,
       null value_convert,
       null stat_label
  from gv$segment_statistics
 where value > 1000000
   and statistic_name in ('physical reads', 'logical reads')
   and owner not in ('SYS', 'SYSTEM')
union all 
  select owner||'.'||object_name||' '||statistic_name||' ('||inst_id||')' stat_name,
       'segment_stats' stat_group,
       'rate' stat_type,
       value,
       null tags,
       null value_convert,
       null stat_label
  from gv$segment_statistics
 where value > 10000
   and statistic_name in ('physical writes')
   and owner not in ('SYS', 'SYSTEM');

