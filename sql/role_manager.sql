set pages 1000 
set lines 512 
col sql_text format a512
set term on 
set feed on
set head on

-- This table may already exist, not a problem if it does.
create table role_manager_tmp (
sql_text varchar2(1024));

-- This script can maintain roles using views.

-- This view will be used to create the roles from the special double underbar views.
create or replace view create_roles as
select 'create role '||replace(view_name, 'ROLE__', '') ||';' sql_text 
  from user_views 
 where view_name like 'ROLE\_\_%' escape '\'
   and replace(view_name, 'ROLE__', '') not in (select role from dba_roles);

-- This is a simple example of a double underbar view. SQL_TEXT is required. You can add any other columns you want. The name must start with ROLE__. SQL_TEXT contains the SQL that will get run. It should end in ";".

-- create or replace view ROLE__MY_ROLE as 
-- select 'grant select any table to g;' sql_text,
--        'This is a comment about what this grant exists.' note 
--   from dual;

-- Creates roles from ROLE__ views.
set term off 
set feed off
set head off
spool sql_text.tmp
select 'select 1 from dual;' from dual;
select sql_text from create_roles where lower(sql_text) like '%create role%';
spool off
set term on 
set feed on
set head on
@sql_text.tmp

-- Runs the grants or revokes returned from each view.
declare
   cursor role_views is 
   select view_name 
     from user_views 
    where view_name like 'ROLE\_\_%' escape '\';
    c sys_refcursor;
    t role_manager_tmp%rowtype;
begin
    for v in role_views loop
       open c for 'select sql_text from '||v.view_name; 
       loop
         fetch c into t.sql_text;
         exit when c%notfound;
         insert into role_manager_tmp (sql_text) values (t.sql_text);
       end loop;
    end loop;
end;
/

set term off 
set feed off
set head off
spool grant_privs.tmp
select 'select 1 from dual;' from dual;
select sql_text from role_manager_tmp;
spool off
set term on 
set feed on
set head on
@grant_privs.tmp

drop table role_manager_tmp;

select * from role__g_read_all;

create or replace view read_all_roles as (
select username from dba_users 
 where oracle_maintained != 'Y'
   and username in ('LOAN', 'FIRE', 'SLDEV'));
  
create or replace view modify_all_roles as (
select username from dba_users where oracle_maintained != 'Y'
  and username in ('LOAN', 'FIRE', 'SLDEV'));

spool create_roles.tmp
select 'create role '||username||'_READ_ALL;' sql_text from read_all_roles where username||'_READ_ALL' not in (select role from dba_roles);
@create_roles.tmp

insert into sql_text_tmp (sql_text) (
select 'grant select on '||a.owner||'.'||a.table_name||' to '||a.owner||'_READ_ALL;' sql_text
  from dba_tables a,
       read_all_roles b
 where a.owner=b.username
   and not exists (select 'x'
                     from dba_tab_privs c 
                    where c.owner=a.owner
                      and c.table_name=a.table_name));
    
set term off 
set feed off
set head off
spool sql_text.tmp
select 'select 1 from dual;' from dual;
select sql_text from sql_text_tmp;
spool off
set term on 
set feed on
set head on
@sql_text.tmp
delete from sql_text_tmp;


--                            
--select 'revoke '||privilege||' on '||owner||'.'||table_name||' from '||grantee||';' revoke_sql from dba_tab_privs where grantee='G_READ_ALL';
-- 
--drop role g_read_all;
