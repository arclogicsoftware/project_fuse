create or replace view alert__fra_space as
select 'warning' alert_level,
       name||'('||con_id||') FRA % Full Alert' alert_name,
       name|| ' flash recovery is '||pct_full_reclaimable||'% full' alert_info,
       'flash_recovery_area' alert_type
  from flash_recovery_area_space a
 where pct_full_reclaimable > 75;