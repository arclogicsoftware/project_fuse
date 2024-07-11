

create or replace view arch_dest_status_time as 
select (select min(first_time) first_time from gv$log_history d where d.inst_id=a.inst_id and d.sequence#=a.applied_seq#)  applied_first_time,
       (select min(first_time) first_time from gv$log_history e where e.inst_id=a.inst_id and e.sequence#=a.archived_seq#)  archived_first_time,
       a.*
  from gv$archive_dest_status a where archived_seq# > 0 and applied_seq# > 0;