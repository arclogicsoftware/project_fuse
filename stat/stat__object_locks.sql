
create or replace view stat__object_locks as
select 'max_lock_seconds' stat_name,
       'oracle_locking' stat_group,
       nvl(max(seconds), 0) value,
       'value' stat_type,
       null tags,
       null value_convert,
       null stat_label
  from lockers
union all
select 'lockers_view_row_count' stat_name,
       'oracle_locking' stat_group,
       count(*) value,
       'value' stat_type,
       null tags,
       null value_convert,
       null stat_label
  from lockers
union all
select 'max_wanting_seconds' stat_name,
       'oracle_locking' stat_group,
       nvl(max(seconds), 0) value,
       'value' stat_type,
       null tags,
       null value_convert,
       null stat_label
  from lockers
 where wanting is not null
union all
select 'sessions_blocked_count' stat_name,
       'oracle_locking' stat_group,
       count(distinct sid||'-'||inst_id) value,
       'value' stat_type,
       null tags,
       null value_convert,
       null stat_label
  from lockers
 where wanting is not null;

 

 