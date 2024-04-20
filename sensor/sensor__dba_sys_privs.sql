create or replace view sensor__dba_sys_privs as
select 'grantee='||grantee||' '||
       'priv='||privilege||' '||
       'admin='||admin_option name,
       null value
  from dba_sys_privs
 group
    by grantee,
       privilege,
       admin_option
 order 
    by grantee,
       privilege,
       admin_option;