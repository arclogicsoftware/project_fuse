


create or replace procedure daily_am as 
begin
   update alert_table set ready_notify=1 where closed is null;
   delete from blocked_sessions_hist where insert_time > systimestamp-31;
   delete from sensor_hist 
    where sensor_id=(select sensor_id from sensor_table where sensor_view='sensor__session_user_programs')
      and created < systimestamp-90;
   delete from stat_table where stat_group='oracle_sessions' and value_time < systimestamp-7;
   commit;
end;
/

create or replace procedure apply_alert_rules as 
begin
   update alert_table set ready_notify=1 where notify_count=0;

   -- if sql%rowcount > 0 then
   --    update alert_table set ready_notify=1 where closed is null;
   -- end if;

   -- update alert_table set ready_notify=1
   --  where closed is not null
   --    and notify_count > 0
   --    and closed > last_notify;

   -- if sql%rowcount > 0 then
   --    update alert_table set ready_notify=1 where closed is null;
   -- end if;

   -- update alert_table set ready_notify=1
   --  where notify_count > 0 
   --    and alert_level not in ('info')
   --    and closed is null
   --    -- Hours
   --    and secs_between_timestamps(last_notify, systimestamp)/60/60 > 8;

   --  if sql%rowcount > 0 then
   --    update alert_table set ready_notify=1 where closed is null;
   --  end if;
   commit;
end;
/

exec drop_table('test_table');
begin
   if not does_table_exist('test_table') then 
      execute immediate '
      create table test_table (
      test_id number generated always as identity,
      test_name varchar2(1024) not null,
      last_try timestamp default null,
      -- pass, fail, error
      status varchar2(8) default null,
      status_time timestamp default null,
      test_group varchar2(256) default null)';
   end if;
   add_primary_key('test_table', 'test_id');
   if not does_index_exist('test_table_1') then 
      execute immediate 'create unique index test_table_1 on test_table(test_name)';
   end if;
end;
/

create or replace procedure init_test (
   p_name in varchar2,
   p_group in varchar2 default null) is 
begin
   assert.g_test_table.test_name := p_name;
   assert.g_test_table.test_group := p_group;
   fail_test;
end;
/

create or replace procedure pass_test (
   p_name in varchar2 default assert.g_test_table.test_name,
   p_group in varchar2 default assert.g_test_table.test_group) is 
begin 
   -- Assume it is already passing
   update test_table set last_try=systimestamp
    where test_name=assert.g_test_table.test_name and nvl(test_group, '~')=nvl(assert.g_test_table.test_group, '~')
      and status = 'pass';
   if sql%rowcount = 0 then 
      -- Maybe was not already passing
      update test_table set status='pass', last_try=systimestamp, status_time=systimestamp
       where test_name=assert.g_test_table.test_name and nvl(test_group, '~')=nvl(assert.g_test_table.test_group, '~')
         and status != 'pass';
      if sql%rowcount = 0 then
         -- Row must not exist yet
         if sql%rowcount = 0 then 
            insert into test_table (
            test_name,
            status,
            status_time,
            last_try,
            test_group) values (
            assert.g_test_table.test_name,
            'pass',
            systimestamp,
            systimestamp,
            assert.g_test_table.test_group);
         end if;
      end if;
   end if;
   assert.g_test_table := null;
end;
/

create or replace procedure fail_test is 
begin 
   -- Assume it is already passing
   update test_table set last_try=systimestamp
    where test_name=assert.g_test_table.test_name and nvl(test_group, '~')=nvl(assert.g_test_table.test_group, '~')
      and status = 'fail';
   if sql%rowcount = 0 then 
      -- Maybe was not already passing
      update test_table set status='pass', last_try=systimestamp, status_time=systimestamp
       where test_name=assert.g_test_table.test_name and nvl(test_group, '~')=nvl(assert.g_test_table.test_group, '~')
         and status != 'fail';
      if sql%rowcount = 0 then
         -- Row must not exist yet
         if sql%rowcount = 0 then 
            insert into test_table (
            test_name,
            status,
            status_time,
            last_try,
            test_group) values (
            assert.g_test_table.test_name,
            'fail',
            systimestamp,
            systimestamp,
            assert.g_test_table.test_group);
         end if;
      end if;
   end if;
end;
/



-- declare 
--    n number;
-- begin 
--    set_test (
--       p_name=>'Database has been running for the last 48 hours.',
--       p_group=>'Database');
--    select min(round((sysdate-startup_time)*24)) hrs_running into n from gv$instance;
--    if n < 48 then
--       fail_test;
--    else 
--       pass_test;
--    end if;
-- end;
-- /


create or replace procedure minutely_job as 
begin
   null;
end;
/