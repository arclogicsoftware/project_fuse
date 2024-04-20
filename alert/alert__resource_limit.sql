create or replace view alert__resource_limit as 
select 'info' alert_level,
       'resource_limit_'||resource_name||' ('||inst_id||')' alert_name,
       current_pct_used||'%, cur='||current_utilization||', max='||max_utilization||', lim='||limit_value alert_info,
       'resource_limit' alert_type
  from resource_limit 
 where current_pct_used >= 60 
   and current_pct_used < 80
union all
select 'warning' alert_level,
       'resource_limit_'||resource_name||' ('||inst_id||')' alert_name,
       current_pct_used||'%, cur='||current_utilization||', max='||max_utilization||', lim='||limit_value alert_info,
       'resource_limit' alert_type
  from resource_limit 
 where current_pct_used >= 80 
   and current_pct_used < 90
union all
select 'critical' alert_level,
       'resource_limit_'||resource_name||' ('||inst_id||')' alert_name,
       current_pct_used||'%, cur='||current_utilization||', max='||max_utilization||', lim='||limit_value alert_info,
       'resource_limit' alert_type
  from resource_limit 
 where current_pct_used >= 90;