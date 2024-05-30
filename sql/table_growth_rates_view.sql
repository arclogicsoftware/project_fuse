create or replace view table_growth_rates as 
select segment_name, 
       last_delta,
       start_date,
       last_size_gb,
       start_size_gb,
       last_month_gb,
       this_month_gb,
       decode(days_tracking, 0, 0, round(delta_gb/days_tracking, 2)) gb_per_day,
       round(decode(last_size_gb-last_month_gb-this_month_gb, 0, 0, last_month_gb/(last_size_gb-last_month_gb-this_month_gb))*100) last_month_pct_change,
       round(decode(last_size_gb-this_month_gb, 0, 0, this_month_gb/(last_size_gb-this_month_gb))*100) this_month_pct_change
  from (
select segment_name,
       last_delta,
       round(last_size/1024, 1) last_size_gb,
       round(start_size/1024, 1) start_size_gb,
       start_date,
       round((last_size-start_size)/1024, 1) delta_gb,
       round(sysdate-start_date) days_tracking,
       case to_char(trunc(sysdate, 'MM')-1, 'MON')
          when 'JAN' then round(jan/1024, 1)
          when 'FEB' then round(feb/1024, 1)
          when 'MAR' then round(mar/1024, 1)
          when 'APR' then round(apr/1024, 1)
          when 'MAY' then round(may/1024, 1)
          when 'JUN' then round(jun/1024, 1)
          when 'JUL' then round(jul/1024, 1)
          when 'AUG' then round(aug/1024, 1)
          when 'SEP' then round(sep/1024, 1)
          when 'OCT' then round(oct/1024, 1)
          when 'NOV' then round(nov/1024, 1)
          when 'DEC' then round(dec/1024, 1)
        end as last_month_gb,
        case to_char(trunc(sysdate, 'MM'), 'MON')
          when 'JAN' then round(jan/1024, 1)
          when 'FEB' then round(feb/1024, 1)
          when 'MAR' then round(mar/1024, 1)
          when 'APR' then round(apr/1024, 1)
          when 'MAY' then round(may/1024, 1)
          when 'JUN' then round(jun/1024, 1)
          when 'JUL' then round(jul/1024, 1)
          when 'AUG' then round(aug/1024, 1)
          when 'SEP' then round(sep/1024, 1)
          when 'OCT' then round(oct/1024, 1)
          when 'NOV' then round(nov/1024, 1)
          when 'DEC' then round(dec/1024, 1)
        end as this_month_gb
   from obj_size_data
  where segment_type='TABLE');