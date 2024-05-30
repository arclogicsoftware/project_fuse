
/*

alter system flush shared_pool;
select * from v$parameter where upper(name) in ('OPTIMIZER_USE_SQL_PLAN_BASELINES', 'OPTIMIZER_CAPTURE_SQL_PLAN_BASELINES', 'STATISTICS_LEVEL');
select * from dba_sql_profiles;
select * from dba_sql_plan_baselines;
select * from dba_feature_usage_statistics order by 4 desc;

*/

declare
    p_table varchar2(128) := 'FQ64005';
    p_owner varchar2(128) := 'PRODDTA';
begin
    dbms_stats.gather_table_stats (
       ownname=>p_owner,
       tabname=>upper(p_table),
       estimate_percent=>dbms_stats.auto_sample_size,
       method_opt=>'FOR ALL COLUMNS SIZE AUTO',
       cascade=>true);
end;
/

define v_sql_id='c3gdcq05qw9u6'
define v_task_name='tunec3gdcq05qw9u6'
define v_time_limit=1200

declare
  task_id varchar2(128);
begin
 task_id := dbms_sqltune.create_tuning_task(
   sql_id      => '&v_sql_id',
   scope       => dbms_sqltune.scope_comprehensive,
   time_limit  => &v_time_limit,
   task_name   => '&v_task_name');
 dbms_sqltune.execute_tuning_task(task_name => '&v_task_name');
end;
/

set long 10000;
set pagesize 1000
set linesize 200
select dbms_sqltune.report_tuning_task('&v_task_name') as recommendations from dual;
set pagesize 24

-- execute dbms_sqltune.create_sql_plan_baseline(task_name =>'tune9m5hdjk3nfbc3', owner_name => 'epost', plan_hash_value =>3417224033);
-- alter system flush shared_pool;