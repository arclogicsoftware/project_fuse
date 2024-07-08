
delete from log_table;
delete from alert_table where alert_name='test';

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
      systimestamp, -- opened
      systimestamp, -- updated
      null, -- closed
      null, -- last_eval
      null, -- alert_view
      0, -- alert_delay
      0); -- notify_interval
end;
/

declare
   n number;
   a alert_table%rowtype;
   procedure fetch_app_alert_test_row is
   begin 
      select * into a from alert_table where alert_name='test';
   end;
begin
   
   insert_alert_test;

   -- Basic test, add row, evaluate, and it should be marked ready to notify.
   init_test('app_alert_test_1');
   fetch_app_alert_test_row;
   assert(a.ready_notify=0, 'ready_notify should be 0 if app_alert.evaluate_alerts has not run.');
   app_alert.evaluate_alerts;
   fetch_app_alert_test_row;
   assert(a.ready_notify=1, 'Running app_alert.evaluate_alerts should mark it ready notify.');
   pass_test;

   -- Run check_ready_notify, notification should be sent, ready_notify should be reset, there should be a last_notify timestamp.
   init_test('app_alert_test_2');
   check_ready_notify;
   fetch_app_alert_test_row;
   assert(a.notify_count=1, 'Alert should have notified.');
   assert(a.ready_notify=0, 'Ready notify should have been reset back to zero.');
   assert(a.last_notify is not null, 'Last notify should be set.');
   pass_test;
   
   -- Test that the alert does not notify again. Notify interval is 0 so this should only notify once.
   init_test('app_alert_test_3');
   app_alert.evaluate_alerts;
   check_ready_notify;
   fetch_app_alert_test_row;
   assert(a.notify_count=1, 'Notification count should still be 1.');
   assert(a.ready_notify=0, 'Ready notify should still be 0.');
   pass_test;

   -- Add a notification interval and test.
   init_test('app_alert_test_4');
   update alert_table set last_notify = last_notify - interval '2' minute, notify_interval=1 
    where alert_name='test';
   app_alert.evaluate_alerts;
   check_ready_notify;
   fetch_app_alert_test_row;
   assert(a.notify_count=2, 'Alert should have notified a second time now.');
   assert(a.ready_notify=0, 'Ready notify should have been reset back to zero.');
   pass_test;

    -- Test that the alert does not notify again if we run eval and check.
   init_test('app_alert_test_5');
   app_alert.evaluate_alerts;
   check_ready_notify;
   fetch_app_alert_test_row;
   assert(a.notify_count=2, 'Notification count should still be 2.');
   assert(a.ready_notify=0, 'Ready notify should still be 0.');
   pass_test;

   -- Test alert delay.
   init_test('app_alert_test_6');
   insert_alert_test;
   update alert_table set alert_delay=60, opened=opened - interval '45' minute
    where alert_name='test';
   app_alert.evaluate_alerts;
   check_ready_notify;
   fetch_app_alert_test_row;
   assert(a.ready_notify=0, 'Alert should not be ready to notify yet.');
   assert(a.notify_count=0, 'Notification count should still be 0.');
   update alert_table set alert_delay=30, opened=opened - interval '45' minute
    where alert_name='test';
   app_alert.evaluate_alerts;
   check_ready_notify;
   fetch_app_alert_test_row;
   assert(a.notify_count=1, 'Notification count should still be 1.');
   pass_test;

end;
/

select * from alert_table where alert_name='test';
select * from log_table order by 1 desc;

