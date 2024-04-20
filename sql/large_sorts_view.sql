

-- Initially set the definition of a large sort to 50% of the max sort tablespace size.
declare
   n number;
begin
   select max(size_in_gb)*.5 into n from sort_info;
   app_config.add_param_num(p_name=>'large_sort_size_gb', p_num=>n);
end;
/

create or replace view large_sorts as
select distinct
  c.sql_text,
  b.sid,
  b.username,
  b.osuser,
  b.machine,
  a.extents,
  round(a.blocks*8192/1024/1024/1024,1) size_gb,
  systimestamp created
from
  gv$sort_usage a,
  gv$session b,
  gv$sqlarea c
where 
  a.blocks*8192/1024/1024/1024 > app_config.get_param_num(p_name=>'large_sort_size_gb', p_default=>10) and
  a.inst_id = b.inst_id(+) and
  a.inst_id = c.inst_id(+) and
  a.session_addr = b.saddr(+) and
  a.sqladdr = c.address(+) and 
  a.sqlhash = c.hash_value(+)
/

exec drop_table('large_sort_hist');
begin 
   if not does_table_exist('large_sort_hist') then 
      execute immediate 'create table large_sort_hist as (select * from large_sorts where 1=2)';
   end if;
end;
/

