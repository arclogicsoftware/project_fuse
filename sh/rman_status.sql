column operation format a45 trunc
column status format a27 trunc
column gb format 999999
column hours format 9999.9
column end_day format a12
column row_count format 99999

set lines 140
set pages 100

select sys_context('userenv', 'db_name') service from dual;

select
    a.status,
    a.operation||' '||a.object_type||' '||a.output_device_type operation,
    sum(round(a.mbytes_processed / 1024, 2)) as gb,
    sum(round((a.end_time - a.start_time) * 24, 1)) as hours,
    to_char(a.end_time, 'YYYY-MM-DD') as end_day,
    count(*) as row_count
from v$rman_status a
where a.start_time > sysdate-30
group by
    a.operation,
    a.status,
    a.object_type,
    a.output_device_type,
    to_char(a.end_time, 'YYYY-MM-DD')
order by 5 desc;