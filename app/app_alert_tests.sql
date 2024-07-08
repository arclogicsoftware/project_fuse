
delete from log_table;
delete from alert_table;

create or replace procedure insert_alert_test as
begin
   delete from alert_table where alert_name='test';
   insert into alert_table (
      alert_level,
      alert_name,
      alert_info,
      alert_type,
      notify_count,
      last_notify,
      ready_notify,
      opened,
      updated,
      closed,
      last_eval,
      alert_view,
      alert_delay,
      notify_interval
      ) values (
      'warning', -- alert_level
      'test', -- alert_info
      null, -- alert_info
      'test', -- alert_type
      0, -- notify_count
      null, -- last_notify
      0, -- ready_notify
      SYSTIMESTAMP at time zone 'UTC', -- opened
      SYSTIMESTAMP at time zone 'UTC', -- updated
      null, -- closed
      null, -- last_eval
      null, -- alert_view
      0, -- alert_delay
      0); -- notify_interval
end;
/

declare
   n number;
begin
   init_test('app_alert_test_1');
   insert_alert_test;
   app_alert.evaluate_alerts;
   select count(*) into n from alert_table where alert_name='test' and ready_notify=1 and notify_count=0 and last_notify is null and closed is null;
   assert(n=1, 'Alert should be ready to notify');
   check_ready_notify;
   select count(*) into n from alert_table where alert_name='test' and ready_notify=0 and notify_count=1 and last_notify is not null and closed is null;
   assert(n=1, 'Alert should have notified');
   update alert_table set last_notify = last_notify - interval '2' minute, notify_interval=1 where alert_name='test';
   app_alert.evaluate_alerts;
   select count(*) into n from alert_table where alert_name='test' and ready_notify=1 and notify_count=1 and last_notify is not null and closed is null;
   assert(n=1, 'Alert should be ready to notify again');
   check_ready_notify;
   select count(*) into n from alert_table where alert_name='test' and ready_notify=0 and notify_count=2 and last_notify is not null and closed is null;
   assert(n=1, 'Alert should have notified again');
   pass_test;
end;
/

exec check_ready_notify;

select * from alert_table;

select * from log_table order by 1 desc;


select systimestamp, systimestamp 

