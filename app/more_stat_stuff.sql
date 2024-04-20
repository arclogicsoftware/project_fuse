exec collect_stat.collect;
exec collect_stat.collect;

update stat_table
   set value_convert='/100', stat_label='seconds/sec'
 where stat_group like '%database_stats%' and status='stage'
   and (stat_name like 'parse time cpu%'
    or  stat_name like 'recursive cpu usage%'
    or  stat_name like 'CPU used %'
    or  stat_name like 'cell smart IO % CPU time%'
    or  stat_name like 'DB time%'
    or  stat_name like 'application wait time%'
    or  stat_name like 'user I/O wait time%'
    or  stat_name like 'file io service time%'
    or  stat_name like 'parse time cpu%'
    or  stat_name like 'parse time elapsed%');

update stat_table set value_convert = '/1000', stat_label='k/sec' 
 where stat_name like 'sorts (rows)%'
   and stat_group like '%database_stats%'
   and status='stage';

update stat_table set value_convert = '/1024/1024*60', stat_label='mb/min' 
 where stat_name like 'redo size%'
   and stat_group like '%database_stats%'
   and status='stage';

update stat_table set value_convert = '/100*60', stat_label='seconds/min' 
 where stat_name like 'DB time%'
   and stat_group like '%database_stats%'
   and status='stage';

update stat_table set value_convert = '/1000000*60', stat_label='seconds/min' 
 where stat_name like 'file io wait time %'
   and stat_group like '%database_stats%'
   and status='stage';

update stat_table set value_convert = '/100*60', stat_label='seconds/min' 
 where stat_name like 'user I/O wait time %'
   and stat_group like '%database_stats%'
   and status='stage';

update stat_table set value_convert = '*10/1000*60', stat_label='seconds/min' 
 where stat_name like 'parse time elapsed %'
   and stat_group like '%database_stats%'
   and status='stage';

update stat_table set value_convert = '*10/1000*60', stat_label='seconds/min' 
 where stat_name like 'parse time cpu %'
   and stat_group like '%database_stats%'
   and status='stage';

update stat_table set value_convert = '*60', stat_label='per/min' 
 where stat_name like 'parse count %'
   and stat_group like '%database_stats%'
   and status='stage';

update stat_table set value_convert = '/100*60', stat_label='seconds/min' 
 where stat_group like '%database_wait_time%'
   and status='stage';

update stat_table set value_convert='*60', stat_label='per/min', tags='[!]'
 where (stat_name like 'logons cumulative%' or stat_name like 'user logons cumulative%')
   and stat_group like '%database_stats%';

update stat_table set stat_type='value', tags='[!]'
 where stat_name like 'logons current%'
   and stat_group like '%database_stats%';

update stat_table set status='active' where status='stage';