create or replace view alert__large_sorts as 
select 'info' alert_level,
       'large_sort_'||rownum alert_name,
       'size_gb='||size_gb||', sql_text='||sql_text alert_info,
       'database' alert_type
  from large_sorts;