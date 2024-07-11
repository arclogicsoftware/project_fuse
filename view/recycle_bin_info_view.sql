
create or replace view recycle_bin_info as
select ts_name tablespace_name,
       round(sum(space)*8/1024/1024, 1) gb
  from dba_recyclebin
 where ts_name is not null
 group 
    by ts_name 
order 
    by 2 desc;