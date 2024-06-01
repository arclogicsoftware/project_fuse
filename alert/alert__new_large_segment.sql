create or replace view alert__new_large_segment as
select 'warning' alert_level,
       'NEW SEGMENT: '||segment_name alert_name,
       'size='||last_size||' MB' alert_info,
       'database' alert_type
  from obj_size_data 
 where segment_type!='datafile' 
   and start_date >= trunc(sysdate-1)
   and last_size > 1024;