set pages 100
set lines 120
set feedback off

prompt
prompt Database Info (dbinfo.sql)

set head off
column current_time format a100
select 'Current Time: '||to_char(sysdate, 'YYYY-MM-DD HH24:MI') current_time from dual;
set head on

column instance_name format a15 heading 'Instance'
column host_name format a35 heading 'Host'
column version format a15 heading 'Version'
column archiver format a15 heading 'Archiver'
column instance_role format a20 heading 'Instance Role'

select
   instance_name,
   host_name,
   version,
   archiver,
   instance_role
from gv$instance
/

prompt

column inst_id format 9999 heading "Instance#"
column server_load format 999.9 heading "Server Load"

select inst_id, round(value, 1) server_load
  from gv$osstat 
 where stat_name='LOAD'
 order 
    by 2;

select * from gv$database;

-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/controlfiles.sql
-- Author       : Tim Hall
-- Description  : Displays information about controlfiles.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @controlfiles
-- Last Modified: 21/12/2004
-- -----------------------------------------------------------------------------------

SET LINESIZE 100
COLUMN name FORMAT A80

SELECT name,
       status
FROM   v$controlfile
ORDER BY name;

SET LINESIZE 80

-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/datafiles.sql
-- Author       : Tim Hall
-- Description  : Displays information about datafiles.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @datafiles
-- Last Modified: 17-AUG-2005
-- -----------------------------------------------------------------------------------

SET LINESIZE 200
COLUMN file_name FORMAT A70

SELECT file_id,
       file_name,
       ROUND(bytes/1024/1024/1024) AS size_gb,
       ROUND(maxbytes/1024/1024/1024) AS max_size_gb,
       autoextensible,
       increment_by,
       status
FROM   dba_data_files
ORDER BY file_name;

-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/db_info.sql
-- Author       : Tim Hall
-- Description  : Displays general information about the database.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @db_info
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET PAGESIZE 1000
SET LINESIZE 100
SET FEEDBACK OFF

SELECT *
FROM   v$database;

SELECT *
FROM   v$instance;

SELECT *
FROM   v$version;

SELECT a.name,
       a.value
FROM   v$sga a;

SELECT Substr(c.name,1,60) "Controlfile",
       NVL(c.status,'UNKNOWN') "Status"
FROM   v$controlfile c
ORDER BY 1;

SELECT Substr(d.name,1,60) "Datafile",
       NVL(d.status,'UNKNOWN') "Status",
       d.enabled "Enabled",
       LPad(To_Char(Round(d.bytes/1024000,2),'9999990.00'),10,' ') "Size (M)"
FROM   v$datafile d
ORDER BY 1;

SELECT l.group# "Group",
       Substr(l.member,1,60) "Logfile",
       NVL(l.status,'UNKNOWN') "Status"
FROM   v$logfile l
ORDER BY 1,2;

PROMPT
SET PAGESIZE 14
SET FEEDBACK ON

-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/db_links.sql
-- Author       : Tim Hall
-- Description  : Displays information on all database links.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_links
-- Last Modified: 11/05/2007
-- -----------------------------------------------------------------------------------
SET LINESIZE 150

COLUMN owner FORMAT A30
COLUMN db_link FORMAT A30
COLUMN username FORMAT A30
COLUMN host FORMAT A30

SELECT owner,
       db_link,
       username,
       host
FROM   dba_db_links
ORDER BY owner, db_link;

-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/db_links_open.sql
-- Author       : Tim Hall
-- Description  : Displays information on all open database links.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @db_links_open
-- Last Modified: 11/05/2007
-- -----------------------------------------------------------------------------------
SET LINESIZE 200

COLUMN db_link FORMAT A30

SELECT db_link,
       owner_id,
       logged_on,
       heterogeneous,
       protocol,
       open_cursors,
       in_transaction,
       update_sent,
       commit_point_strength
FROM   v$dblink
ORDER BY db_link;

SET LINESIZE 80


-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/db_properties.sql
-- Author       : Tim Hall
-- Description  : Displays all database property values.
-- Call Syntax  : @db_properties
-- Last Modified: 15/09/2006
-- -----------------------------------------------------------------------------------
COLUMN property_value FORMAT A50

SELECT property_name,
       property_value
FROM   database_properties
ORDER BY property_name;

-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/default_tablespaces.sql
-- Author       : Tim Hall
-- Description  : Displays the default temporary and permanent tablespaces.
-- Requirements : Access to the DATABASE_PROPERTIES views.
-- Call Syntax  : @default_tablespaces
-- Last Modified: 04/06/2019
-- -----------------------------------------------------------------------------------
COLUMN property_name FORMAT A30
COLUMN property_value FORMAT A30
COLUMN description FORMAT A50
SET LINESIZE 200

SELECT *
FROM   database_properties
WHERE  property_name like '%TABLESPACE';

- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/df_free_space.sql
-- Author       : Tim Hall
-- Description  : Displays free space information about datafiles.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @df_free_space.sql
-- Last Modified: 17-AUG-2005
-- -----------------------------------------------------------------------------------

SET LINESIZE 120
COLUMN file_name FORMAT A60

SELECT a.file_name,
       ROUND(a.bytes/1024/1024) AS size_mb,
       ROUND(a.maxbytes/1024/1024) AS maxsize_mb,
       ROUND(b.free_bytes/1024/1024) AS free_mb,
       ROUND((a.maxbytes-a.bytes)/1024/1024) AS growth_mb,
       100 - ROUND(((b.free_bytes+a.growth)/a.maxbytes) * 100) AS pct_used
FROM   (SELECT file_name,
               file_id,
               bytes,
               GREATEST(bytes,maxbytes) AS maxbytes,
               GREATEST(bytes,maxbytes)-bytes AS growth
        FROM   dba_data_files) a,
       (SELeCT file_id,
               SUM(bytes) AS free_bytes
        FROM   dba_free_space
        GROUP BY file_id) b
WHERE  a.file_id = b.file_id
ORDER BY file_name;

-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/directories.sql
-- Author       : Tim Hall
-- Description  : Displays information about all directories.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @directories
-- Last Modified: 04/10/2006
-- -----------------------------------------------------------------------------------
SET LINESIZE 150

COLUMN owner FORMAT A20
COLUMN directory_name FORMAT A25
COLUMN directory_path FORMAT A80

SELECT *
FROM   dba_directories
ORDER BY owner, directory_name;

-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/file_io.sql
-- Author       : Tim Hall
-- Description  : Displays the amount of IO for each datafile.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @file_io
-- Last Modified: 15-JUL-2000
-- -----------------------------------------------------------------------------------
SET PAGESIZE 1000

SELECT Substr(d.name,1,50) "File Name",
       f.phyblkrd "Blocks Read",
       f.phyblkwrt "Blocks Writen",
       f.phyblkrd + f.phyblkwrt "Total I/O"
FROM   v$filestat f,
       v$datafile d
WHERE  d.file# = f.file#
ORDER BY f.phyblkrd + f.phyblkwrt DESC;

SET PAGESIZE 18

set feedback on
