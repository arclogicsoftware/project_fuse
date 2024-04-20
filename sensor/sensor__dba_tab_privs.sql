create or replace view sensor__dba_tab_privs as
select 'grantee='||grantee||' '||
       'obj='||owner||'.'||table_name||' '||
       'grantor='||grantor||' '||
       'priv='||privilege||' '||
       'type='||type name,
       null value
  from dba_tab_privs
 group
    by grantee, owner, table_name, grantor, privilege, type
 order
    by grantee, owner, table_name, grantor, privilege, type;