exec drop_trigger('session_audit_logon_trg');
exec drop_trigger('session_audit_logoff_trg');
exec drop_table('session_audit');
begin
   if not does_table_exist('session_audit') then 
      execute immediate '
      create table session_audit (
      logon_time      date,
      logoff_time     date,
      sid             number,
      audsid          number,
      inst_id         number,
      serial#         number,
      username        varchar2(128),
      osuser          varchar2(128),
      process         varchar2(128),
      module          varchar2(128),
      spid            number,
      machine         varchar2(128),
      program         varchar2(128),
      cpu             number
      )';
   end if;
   if not does_index_exist('session_audit_1') then 
      execute immediate 'create index session_audit_1 on session_audit(logon_time, sid)';
   end if;
   if not does_index_exist('session_audit_2') then 
      execute immediate 'create index session_audit_2 on session_audit(audsid)';
   end if;
end;
/

create or replace trigger session_audit_logon_trg
after logon on database 
declare 
   v_sid     number; 
   v_inst_id number;
   v_serial# number; 
   v_session_id varchar2(128);
begin 
   v_sid := sys_context('userenv', 'sid');
   v_inst_id := sys_context('userenv', 'instance');
   v_session_id := sys_context('userenv', 'sessionid');
   insert into session_audit (
      logon_time, 
      logoff_time, 
      sid, 
      audsid,
      inst_id,
      serial#, 
      username, 
      osuser, 
      process,
      module,
      machine,
      program ) (
   select 
      logon_time, 
      null, 
      sid, 
      audsid,
      inst_id,
      serial#, 
      username, 
      osuser, 
      process, 
      module,
      machine, 
      program 
     from gv$session 
    where audsid=v_session_id
      and sid = v_sid
      and inst_id = v_inst_id); 
   commit;
exception 
   when others then 
      log_text('session_audit_logon_trg: '||dbms_utility.format_error_stack);
end;
/

create or replace trigger session_audit_logoff_trg
   before logoff on database
declare
   v_sid number;
   v_inst_id number;
   v_cpu_secs number := -01;
   v_session_id varchar2(128);
begin
   -- select sid, inst_id into v_sid, v_inst_id from gv$mystat where rownum = 1; 
   v_session_id := sys_context('userenv', 'sessionid');
   begin
      select sid, inst_id into v_sid, v_inst_id from session_audit where audsid=v_session_id;
   exception
      when no_data_found then
         return;
      when others then
         raise;
   end;
   select nvl(sum(round(value/100, 1)), -1) cpu_secs
      into v_cpu_secs
      from gv$sesstat  b
     where b.statistic#=19
       and b.sid=v_sid
       and b.inst_id=v_inst_id;
   update session_audit
      set logoff_time=sysdate,
          cpu=v_cpu_secs
   where audsid=v_session_id
     and logoff_time is null;
   commit;
exception
   when others then
      log_text('session_audit_logoff_trg: '||dbms_utility.format_error_stack);
end;
/

create or replace public synonym session_audit for session_audit;

-- delete from session_audit where audsid in (select audsid from (
-- select (sysdate-logon_time)*24*60,
--        a.*
--   from session_audit a
--  where logoff_time is null
--    and not exists (select 'x' from gv$session where audsid=a.audsid)));
 
-- select (sysdate-logon_time)*24*60,
--        a.*
--   from session_audit a
--  where logoff_time is null
--    and not exists (select 'x' from gv$session where audsid=a.audsid);
   
-- select * from gv$session where sid=289 and inst_id=2;

-- delete from session_audit;
-- delete from log_table;

-- select * from session_audit order by 1 desc;

-- select count(*) from session_audit;

-- select * from log_table order by 1 desc;



