create or replace view process_limit as
select a.inst_id, 
       a.value limit,
       b.total current_value,
       decode(a.value, 0, 0, round(b.total/a.value*100)) pct_used
  from (select inst_id, value from gv$parameter where name like 'processes') a,
       (select inst_id, count(*) total from gv$process group by inst_id) b
 where a.inst_id=b.inst_id;
