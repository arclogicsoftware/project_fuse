
--Patch 6/29/2023
exec drop_view('alert__cpu_alerts');

create or replace view alert__cpu as 
select 'warning' alert_level,
       'cpu_alert' alert_name,
       'avg_cpu_count_in_use='||avg_cpu_count_in_use alert_info,
       'cpu' alert_type
  from (select avg(cpu_count_in_use) avg_cpu_count_in_use from sql_log_hourly_stat a
         where sql_hour >= trunc(sysdate, 'HH24')-4/24
        having avg(cpu_count_in_use) > (select value/2 from v$parameter where name='cpu_count'));