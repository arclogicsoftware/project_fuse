-- select to_char(sysdate, 'YYYY-MM-DD HH24:MI') x, to_char(max(first_time), 'YYYY-MM-DD HH24:MI') y from v$log_history;

set feed off
set serveroutput on
set verify off

declare
   every_n_mins number := nvl(&1, 30);
   first_time date;
   n number;
begin
   select round((sysdate-max(first_time))*24*60) into n from v$log_history;
   if n > every_n_mins then
      execute immediate 'alter system switch logfile';
      dbms_output.put_line('force_log_switch.sql: Executed, n='||n);
   else
      null;
      dbms_output.put_line('force_log_switch.sql: Not required, n='||n);
   end if;
end;
/

