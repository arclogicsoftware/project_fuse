create or replace view sga_info as    
select * from (
select inst_id,
       pool,
       name,
       to_gb(bytes) gb
  from gv$sgastat order by 4 desc)
 where rownum < 6
 order
    by 4 desc
/