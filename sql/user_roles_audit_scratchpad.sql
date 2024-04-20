select owner tables_owned_by,
       grantee can_be_modified_by_role,
       count(distinct table_name) how_many_can_be_modified,
       (select count(*) from dba_tables a where a.owner=b.owner)-count(distinct table_name) how_many_can_not_be_modified
  from dba_tab_privs b
 where grantee in (select role from dba_roles where oracle_maintained='N')
   and grantee not in ('REGISTRYACCESS')
   and privilege in ('INSERT', 'DELETE', 'UPDATE')
   and type='TABLE'
 group
    by owner,
       grantee 
 order
    by 1,2;
    
select owner tables_owned_by,
       grantee can_be_modified_by_user,
       count(distinct table_name) how_many_can_be_modified,
       (select count(*) from dba_tables a where a.owner=b.owner)-count(distinct table_name) how_many_can_not_be_modified
  from dba_tab_privs b
 where grantee in (select username from dba_users where oracle_maintained='N' and account_status != 'LOCKED')
   and owner in (select username from dba_users where oracle_maintained='N' and account_status != 'LOCKED')
   and grantee not in ('REGISTRYACCESS')
   and privilege in ('INSERT', 'DELETE', 'UPDATE')
   and type='TABLE'
 group
    by owner,
       grantee 
 order
    by 1,2;