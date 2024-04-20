select * from v$rman_backup_job_details;

select trunc(start_time), 
       input_type,
       status, 
       round(sum(input_bytes/1024/1024/1024), 1) input_gb,
       round(sum(output_bytes/1024/1024/1024), 1) output_gb,
       round(avg(input_bytes_per_sec/1024/1024)) avg_input_mb_per_sec,
       round(avg(output_bytes_per_sec/1024/1024)) avg_output_mb_per_sec, 
       count(*) total_rows
  from v$rman_backup_job_details 
 group
    by trunc(start_time),
       input_type,
       status 
 order 
    by 1 desc;