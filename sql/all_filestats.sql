set recsep off
set pages 100
set linesize 140

prompt
prompt Total File IO (all_filestats.sql)
prompt =================================================================
prompt File IO statistics since startup.

column dummy noprint
column fno format 9999 heading "File|No"
column file_name format a60 heading 'Name' word_wrapped
column tablespace_name format a15 heading 'Tablespace'
column physical_reads format 9,999,999.9 heading 'Reads|*1000'
column physical_writes format 9,999,999.9 heading 'Writes|*1000'
column avg_read_tim format 99.999 heading 'Avg|Rd|Tim'
column avg_write_tim format 99.999 heading 'Avg|Wt|Tim'
column last_io_time format 99.999 heading 'Last|IO|Time'

break on report
compute sum of physical_reads physical_writes on report

select
   null dummy,
   a.file# fno,
   c.file_name,
   c.tablespace_name,
   round((a.phyrds)/1000,1) physical_reads,
   round((a.phywrts)/1000,1) physical_writes,
   round(decode(a.phyrds, 0, -1, a.readtim/a.phyrds/100), 3) avg_read_tim,
   round(decode(a.phywrts,0, -1, a.writetim/a.phywrts/100), 3) avg_write_tim,
   lstiotim/100 last_io_time
from
   v$filestat a,
   dba_data_files c
where
   a.file# = c.file_id
order by 9 desc
/

