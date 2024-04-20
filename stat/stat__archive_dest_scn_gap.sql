create or replace view stat__archive_dest_scn_gap as
select lower(dest_name)||'_scn_gap' stat_name,
       'database' stat_group,
       'value' stat_type,
       current_scn-applied_scn value,
       null tags,
       null value_convert,
       null stat_label
  from (
select dest_name, status, applied_scn, (select current_scn from v$database) current_scn 
  from v$archive_dest where applied_scn > 0);
