-- =============================================================================
-- sppurge.sql
--
-- Purges Statspack snapshots from database.
--
-- Parameters:
-- &1 Number of days back to begin purging old statspack snapshots.
-- =============================================================================

set ver off

column _hisnapid new_value hisnapid noprint
column _losnapid new_value losnapid noprint

set termout off
select max(snap_id) "_hisnapid" from stats$snapshot where snap_time <  trunc(sysdate)-&1;
select min(snap_id) "_losnapid" from stats$snapshot;
set termout on
undefine 1 _hisnapid _losnapid

set echo on
@${ORACLE_HOME}/rdbms/admin/sppurge.sql

set ver on
