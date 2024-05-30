create or replace view alert__table_growth_rate as
select 'warning' alert_level,
       'TABLE GROWTH RATE: '||segment_name alert_name,
       'growth='||this_month_gb||' GB'||', size='||last_size_gb||' GB' alert_info,
       'database' alert_type
  from table_growth_rates 
 where last_size_gb > 4
   and this_month_pct_change > 15
   -- The alert will only trigger on the delta. Once the table stops growing the alert will close.
   -- Object growth is currently checked daily so in theory alerts will remain open at a minimum of 24 hours
   -- which should be enough time to deal with it.
   and last_delta > 0;