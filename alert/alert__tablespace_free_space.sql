create or replace view alert__tablespace_free_space as
select 'warning' alert_level,
       tablespace_name||' FREE SPACE' alert_name,
       'pct_full='||autoextend_pct_full||', max_days_remaining='||max_days_remaining||', gb_per_day='||gb_per_day alert_info,
       'tablespace' alert_type
  from tsinfo
 where max_days_remaining <= 30
   and gb_per_day > 0;
