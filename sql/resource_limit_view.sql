create or replace view resource_limit as
select inst_id, 
       resource_name, 
       current_utilization, 
       max_utilization, 
       to_number(limit_value) limit_value, 
       con_id, 
       decode(trim(limit_value), '0', 0, decode(trim(limit_value), 'UNLIMITED', 0, round(current_utilization/limit_value*100))) current_pct_used
  from gv$resource_limit 
 where trim(limit_value) != 'UNLIMITED'
   and trim(limit_value) not in '0';