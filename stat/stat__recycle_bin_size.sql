create or replace view stat__recycle_bin_size as 
select 'recycle_bin_size_gb' stat_name,
       'database' stat_group,
       'value' stat_type,
       round(sum(gb), 1) value,
       null tags,
       null value_convert,
       'gb' stat_label
 from recycle_bin_info;