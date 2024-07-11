create or replace view rman_status as 
select operation, 
       status, 
       start_time, 
       end_time,
       round(mbytes_processed/1024) gb_processed, 
       object_type, 
       output_device_type 
  from v$rman_status;

create or replace public synonym rman_status for rman_status;