create or replace view sensor__dba_role_privs as
select 'grantee='||grantee||' '||
       'role='||granted_role||' '||
       'admin='||admin_option name,
       count(*) value
  from dba_role_privs
 group
    by grantee,
       granted_role,
       admin_option
 order
    by grantee, 
       granted_role,
       admin_option;