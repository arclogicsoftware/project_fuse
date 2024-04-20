
-- Required for stat__flash_recovery_area, may not compile in all environments.
create or replace view flash_recovery_area_space as
select round((space_used-space_reclaimable)/space_limit * 100) pct_full_reclaimable,
       round(space_used/space_limit * 100) pct_full,
       round(a.space_limit/1024/1024/1024) space_limit_gb,
       round(a.space_reclaimable/1024/1024/1024) space_reclaimable_gb,
       round(space_used/1024/1024/1024) space_used_gb,
       number_of_files,
       name,
       con_id
  from v$recovery_file_dest a;
/

create or replace public synonym flash_recovery_area_space for flash_recovery_area_space;

create or replace procedure stat__flash_recovery_area is
   v_stat_group varchar2(128);
begin
   v_stat_group := get_db_name ||'[flash_recovery_area]';

   merge into stat_table a
   using flash_recovery_area_space b on (a.stat_name=b.name||' % Full Reclaimable ('||b.con_id||')' and a.stat_group=v_stat_group)
   when matched then
      update set a.value=b.pct_full_reclaimable
   when not matched then
      insert (a.stat_name, a.stat_group, a.status, a.value, a.stat_type, a.stat_label, a.tags)
      values (b.name||' % Full Reclaimable ('||b.con_id||')', v_stat_group, 'stage', b.pct_full_reclaimable, 'value', '%', '[!]');

   merge into stat_table a
   using flash_recovery_area_space b on (a.stat_name=b.name||' % Full ('||b.con_id||')' and a.stat_group=v_stat_group)
   when matched then
      update set a.value=b.pct_full
   when not matched then
      insert (a.stat_name, a.stat_group, a.status, a.value, a.stat_type, a.stat_label, a.tags)
      values (b.name||' % Full ('||b.con_id||')', v_stat_group, 'stage', b.pct_full, 'value', '%', '[!]');

   merge into stat_table a
   using flash_recovery_area_space b on (a.stat_name=b.name||' GB Used ('||b.con_id||')' and a.stat_group=v_stat_group)
   when matched then
      update set a.value=b.space_used_gb
   when not matched then
      insert (a.stat_name, a.stat_group, a.status, a.value, a.stat_type, a.stat_label, a.tags)
      values (b.name||' GB Used ('||b.con_id||')', v_stat_group, 'stage', b.space_used_gb, 'value', null, '[!]');

   merge into stat_table a
   using flash_recovery_area_space b on (a.stat_name=b.name||' File Count ('||b.con_id||')' and a.stat_group=v_stat_group)
   when matched then
      update set a.value=b.number_of_files
   when not matched then
      insert (a.stat_name, a.stat_group, a.status, a.value, a.stat_type, a.stat_label, a.tags)
      values (b.name||' File Count ('||b.con_id||')', v_stat_group, 'stage', b.number_of_files, 'value', null, '[!]');

   merge into stat_table a
   using flash_recovery_area_space b on (a.stat_name=b.name||' GB Reclaimable ('||b.con_id||')' and a.stat_group=v_stat_group)
   when matched then
      update set a.value=b.space_reclaimable_gb
   when not matched then
      insert (a.stat_name, a.stat_group, a.status, a.value, a.stat_type, a.stat_label, a.tags)
      values (b.name||' GB Reclaimable ('||b.con_id||')', v_stat_group, 'stage', b.space_reclaimable_gb, 'value', null, '[!]');

end;
/
