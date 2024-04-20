select * from v$archived_log;

select trunc(first_time) first_time,
       dest_id,
       standby_dest,
       archived,
       applied,
       deleted,
       round(max((completion_time-first_time)*24*60)) max_time_to_complete_min,
       -- is_recovery_file_dest,
       sum(backup_count) backup_count,
       status
  from v$archived_log 
 group
    by trunc(first_time),
       dest_id,
       standby_dest,
       archived,
       applied,
       deleted,
       -- is_recovery_file_dest,
       status
 order
    by 1 desc;
    
select trunc(first_time) first_time,
       standby_dest,
       archived,
       applied,
       deleted,
       round(max((completion_time-first_time)*24*60)) max_time_to_complete_min,
       -- is_recovery_file_dest,
       sum(backup_count) backup_count,
       status,
       count(*) total_rows
  from v$archived_log 
 where standby_dest!='YES'
 group
    by trunc(first_time),
       standby_dest,
       archived,
       applied,
       deleted,
       -- is_recovery_file_dest,
       status
 order
    by 1 desc;