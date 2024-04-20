create or replace view active_sorts as
select   b.tablespace
       , b.segfile#
       , b.segblk#
       , round (  (  ( b.blocks * p.value ) / 1024 / 1024 / 1024), 2 ) size_gb
       , a.sid
       , a.inst_id
       , a.serial#
       , a.username
       , a.osuser
       , a.program
       , a.status
    from gv$session a
       , gv$sort_usage b
       , gv$process c
       , v$parameter p
   where p.name = 'db_block_size'
     and a.saddr = b.session_addr
     and a.inst_id = b.inst_id
     and a.paddr = c.addr
     and a.inst_id = c.inst_id
     and a.status!='active'
     and round ((( b.blocks * p.value)/1024/1024/1024), 2) > 0
order by b.tablespace
       , b.segfile#
       , b.segblk#
       , b.blocks;