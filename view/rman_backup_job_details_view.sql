create or replace view rman_backup_job_details as 
select trunc(start_time) start_time,
       to_gb(output_bytes) output_gb,
       output_device_type,
       status,
       round(elapsed_seconds/60) elapsed_minutes,
       input_type
       from v$rman_backup_job_details;