create or replace view stat__resource_limit as
select resource_name||' ('||inst_id||')' stat_name,
       'resource_limit' stat_group,
       'value' stat_type,
       current_utilization value,
       '[!]' tags,
       null value_convert,
       null stat_label
  from resource_limit
union all
select resource_name||'_pct_used ('||inst_id||')' stat_name,
       'resource_limit' stat_group,
       'value' stat_type,
       current_pct_used value,
       '[!]' tags,
       null value_convert,
       null stat_label
  from resource_limit;