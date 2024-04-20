create or replace view stat__asm as
select 'asm_group_'||lower(group_name)||'_total_gb' stat_name,
       'asm' stat_group,
       'value' stat_type,
       total_gb value,
       null tags,
       null value_convert,
       null stat_label
  from asm_space
union all
select 'asm_group_'||lower(group_name)||'_used_gb' stat_name,
       'asm' stat_group,
       'value' stat_type,
       used_gb value,
       null tags,
       null value_convert,
       null stat_label
  from asm_space
union all
select 'asm_group_'||lower(group_name)||'_pct_used' stat_name,
       'asm' stat_group,
       'value' stat_type,
       pct_used value,
       null tags,
       null value_convert,
       null stat_label
  from asm_space;
    