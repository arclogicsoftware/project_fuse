create or replace view alert__rman_status as
select 'warning' alert_level,
       upper('rman_'||to_char(start_time, 'YYYYMMDD_HH24MI')||'_'||operation||'_'||object_type) alert_name,
       'status='||status||', gb_processed='||gb_processed alert_info,
       'database' alert_type
  from rman_status
 where status = 'FAILED'
   and end_time >= sysdate;