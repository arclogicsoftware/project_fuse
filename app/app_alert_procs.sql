
create or replace function alert_can_open_yn (
   p_alert_name in varchar2,
   p_alert_level in varchar2,
   p_alert_info in varchar2,
   p_alert_type in varchar2,
   p_alert_view in varchar2) return varchar2 is 
begin
   return 'y';
end;
/

create or replace function alert_can_notify_yn (
   p_alert_name in varchar2,
   p_alert_level in varchar2,
   p_alert_info in varchar2,
   p_alert_type in varchar2,
   p_alert_view in varchar2) return varchar2 is 
begin
   if p_alert_level = 'info' then 
      return 'n';
   end if;
   return 'y';
end;
/

exec drop_view('alerts_notify_report');

create or replace view alerts_ready_notify as
select decode(closed, null, 'OPEN', 'CLOSED') status,
       a.alert_level,
       a.alert_name,
       a.alert_type,
       mins_between_timestamps(opened, nvl(closed, systimestamp))/60 hrs_open,
       a.alert_info,
       a.notify_count,
       a.alert_id
  from alert_table a
 where ready_notify=1;

create or replace trigger insert_alert_table_trg 
   before insert or update on alert_table for each row 
begin 
   :new.alert_info := substr(:new.alert_info, 1, 4000);
end;
/

create or replace procedure check_ready_notify as 
   cursor alerts is select * from alerts_ready_notify;
begin 
   for a in alerts loop
      -- ToDo: Add code to send alerts
      debug('Fake send email for alert: '||a.alert_name);
      update alert_table
         set ready_notify=0,
             last_notify=systimestamp
       where alert_id=a.alert_id;
   end loop;
end;
/
