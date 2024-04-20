create or replace view asm_space as
select
    name                                     group_name
  , sector_size                              sector_size
  , block_size                               block_size
  , allocation_unit_size                     allocation_unit_size
  , state                                    state
  , type                                     type
  , round(total_mb/1024, 1)                  total_gb
  , round((total_mb - free_mb)/1024, 1)      used_gb
  , round((1- (free_mb / total_mb))*100)     pct_used
from
    v$asm_diskgroup
/