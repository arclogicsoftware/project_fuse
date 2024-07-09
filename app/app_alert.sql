-- Create a custom version of this function in modifications.sql to supress or allow alert notifications.
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

-- Create a custom version of this function in modifications.sql file to supress or allow opening alerts.
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

-- ----------------------------------------------------------------------
-- Do not modify objects below here in your modifications.sql file.
-- ----------------------------------------------------------------------

-- This view is used to determine which alerts are ready to be notified.
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

-- This procedure uses the view above to send notifications if the job which calls it is enabled.
create or replace procedure check_ready_notify as 
	cursor alerts is select * from alerts_ready_notify;
begin 
	for a in alerts loop
		-- ToDo: Add code to send alerts
		debug('Fake send email for alert: '||a.alert_name);
		update alert_table
			set ready_notify=0,
				 last_notify=systimestamp,
				 notify_count=notify_count+1
		 where alert_id=a.alert_id;
	end loop;
end;
/

-- This job called the procedure above if it is enabled. It is not enabled by default.
-- Enable the job manually or in your modifications.sql file if that is desired.
-- exec drop_scheduler_job('check_ready_notify_job');
begin
  if not does_scheduler_job_exist('check_ready_notify_job') then 
	  dbms_scheduler.create_job (
		 job_name        => 'check_ready_notify_job',
		 job_type        => 'PLSQL_BLOCK',
		 job_action      => 'begin check_ready_notify; end;',
		 start_date      => systimestamp,
		 repeat_interval => 'freq=minutely;interval=5',
		 enabled         => false);
	end if;
end;
/
