-- exec drop_view('table_size_summary');
create or replace view table_size_summary  as 
select tablespace_name,
       owner,
       table_name,
       sum(gb) gb,
       tablespace_name||'.'||owner||'.'||table_name segment_full_name
  from (
select tablespace_name,
       owner,
       case
          when gb < app_config.get_param_num('small_table_gb_limit') then 'SMALL_TABLE'
          else table_name
       end as table_name,
       gb
  from (
select tablespace_name, 
       owner, 
       table_name, 
       round(sum(bytes/1024/1024/1024), 2) gb
  from (
select b.tablespace_name, 
       b.owner, 
       b.table_name, 
       a.bytes
  from dba_segments a,
       dba_tables b
 where a.segment_type='TABLE'
   and a.segment_name=b.table_name
   and a.owner=b.owner
   and a.tablespace_name=b.tablespace_name
union all
select b.tablespace_name, 
       b.owner, 
       b.table_name,
       a.bytes
  from dba_segments a,
       dba_indexes b
 where a.segment_type='INDEX'
   and a.segment_name=b.index_name
   and a.owner=b.owner
   and a.tablespace_name=b.tablespace_name)
 group 
    by tablespace_name, 
       owner, 
       table_name))
 group
    by tablespace_name,
       owner,
       table_name,
       tablespace_name||'.'||owner||'.'||table_name
/