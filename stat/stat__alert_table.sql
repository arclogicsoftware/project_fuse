create or replace view stat__alert_table as 
select 'open_alerts_level_'||alert_level stat_name,
       'alerts' stat_group,
       'value' stat_type,
       count(*) value,
       null tags,
       null value_convert,
       null stat_label
  from alert_table 
 where closed is null
 group
    by alert_level;