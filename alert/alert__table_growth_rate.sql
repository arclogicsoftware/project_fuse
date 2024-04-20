create or replace view alert__table_growth_rate as
select 'warning' alert_level,
       'TABLE GROWTH RATE: '||segment_name alert_name,
       'growth='||this_month_gb||' GB'||', size='||last_size_gb||' GB' alert_info,
       'database' alert_type
  from table_growth_rates 
 where last_size_gb > 2
   and this_month_pct_change > 15;