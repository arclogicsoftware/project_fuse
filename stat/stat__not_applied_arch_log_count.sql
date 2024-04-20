
exec drop_view('stat__not_applied_arch_log_count');

create or replace view stat__not_app_arch_log_count as
select 'dest_id_'||dest_id||'_unapplied_arch_log_count' stat_name,
       'database' stat_group,
       'value' stat_type,
       count(*) value,
       null tags,
       null value_convert,
       null stat_label    
  from gv$archived_log 
 where standby_dest='YES' 
   and applied != 'YES'
 group
    by dest_id;