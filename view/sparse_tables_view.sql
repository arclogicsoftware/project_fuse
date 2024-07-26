create or replace view sparse_tables as
select
       a.owner,
       table_name,
       round((avg_row_len*num_rows)/1024/1024,1) estimated_size_mb,
       round(b.bytes/1024/1024,1) actual_size_mb,
       round(b.bytes/1024/1024,1) - round((avg_row_len*num_rows)/1024/1024,1) delta_mb
  from
       dba_tables a,
       dba_segments b
 where
       a.table_name = b.segment_name
       and b.segment_type = 'TABLE'
       and a.owner = b.owner
       and round(b.bytes/1024/1024,1) > 10
       and 1 - decode(round(b.bytes/1024/1024,1), 0, 0, 
               round((avg_row_len*num_rows)/1024/1024,1) / round(b.bytes/1024/1024,1)) >= 30/100
 order
    by 5 desc
/
