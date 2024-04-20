create or replace view alert__process_limit as
select 'info' alert_level,
       'process_limit'||' ('||inst_id||')' alert_name,
       pct_used||'%' alert_info,
       'process_limit' alert_type
  from process_limit 
 where pct_used >= 60 
   and pct_used < 80
union all
select 'warning' alert_level,
       'process_limit'||' ('||inst_id||')' alert_name,
       pct_used||'%' alert_info,
       'process_limit' alert_type
  from process_limit 
 where pct_used >= 80 
   and pct_used < 90
union all
select 'critical' alert_level,
       'process_limit'||' ('||inst_id||')' alert_name,
       pct_used||'%' alert_info,
       'process_limit' alert_type
  from process_limit 
 where pct_used >= 90;