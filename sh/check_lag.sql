set serveroutput on
set head off
set feed off
set verify off

declare
   n number;
begin
   select round((sysdate-max(next_time))*24*60) into n
     from gv$archived_log
    where next_time is not null
      and applied != 'NO';
   if n > nvl(&1, 60) then
      dbms_output.put_line('lag_minutes='||n);
   end if;
end;
/
