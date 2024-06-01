

-- exec drop_table('backup_dba_tab_privs');
-- exec drop_table('backup_dba_sys_privs');
-- exec drop_table('backup_dba_role_privs');

begin
   if not does_table_exist('backup_dba_tab_privs') then 
      execute immediate 'create table backup_dba_tab_privs (
      grantee varchar2(128),
      owner varchar2(128),
      table_name varchar2(128),
      grantor varchar2(128),
      privilege varchar2(128),
      grantable varchar2(128),
      hierarchy varchar2(128),
      common varchar2(128),
      type varchar2(128),
      label varchar2(128),
      created date default sysdate)';
   end if;
   if not does_index_exist('backup_dba_tab_privs_01') then 
      execute immediate 'create index backup_dba_tab_privs_01 on backup_dba_tab_privs (grantee)';
   end if;
   if not does_index_exist('backup_dba_tab_privs_02') then 
      execute immediate 'create index backup_dba_tab_privs_02 on backup_dba_tab_privs (label)';
   end if;
   if not does_index_exist('backup_dba_tab_privs_03') then 
      execute immediate 'create index backup_dba_tab_privs_03 on backup_dba_tab_privs (created)';
   end if;
end;
/

begin
   if not does_table_exist('backup_dba_sys_privs') then 
      execute immediate 'create table backup_dba_sys_privs (
      grantee varchar2(128),
      privilege varchar2(128),
      admin_option varchar2(128),
      common varchar2(128),
      inherited varchar2(128),
      label varchar2(128),
      created date default sysdate)';
   end if;
   if not does_index_exist('backup_dba_sys_privs_01') then 
      execute immediate 'create index backup_dba_sys_privs_01 on backup_dba_sys_privs (grantee)';
   end if;
   if not does_index_exist('backup_dba_sys_privs_02') then 
      execute immediate 'create index backup_dba_sys_privs_02 on backup_dba_sys_privs (label)';
   end if;
   if not does_index_exist('backup_dba_sys_privs_03') then 
      execute immediate 'create index backup_dba_sys_privs_03 on backup_dba_sys_privs (created)';
   end if;
end;
/      

begin
   if not does_table_exist('backup_dba_role_privs') then 
      execute immediate 'create table backup_dba_role_privs (
      grantee varchar2(128),
      granted_role varchar2(128),
      admin_option varchar2(3),
      delegate_option varchar2(128),
      default_role varchar2(128),
      common varchar2(128),
      inherited varchar2(128),
      label varchar2(128),
      created date default sysdate)';
   end if;
   if not does_index_exist('backup_dba_role_privs_01') then 
      execute immediate 'create index backup_dba_role_privs_01 on backup_dba_role_privs (grantee)';
   end if;
   if not does_index_exist('backup_dba_role_privs_02') then 
      execute immediate 'create index backup_dba_role_privs_02 on backup_dba_role_privs (label)';
   end if;
   if not does_index_exist('backup_dba_role_privs_03') then 
      execute immediate 'create index backup_dba_role_privs_03 on backup_dba_role_privs (created)';
   end if;
end;
/      

-- exec drop_procedure('backup_tab_privs');
create or replace procedure backup_privs (
    p_label in varchar2 default null,
    p_username in varchar2 default null) is 
    v_label varchar2(128) := nvl(p_label, to_char(sysdate, 'YYYYMMDDHH24MISS'));
begin
    
    delete from backup_dba_tab_privs where label=v_label;
    delete from backup_dba_sys_privs where label=v_label;
    delete from backup_dba_role_privs where label=v_label;
    
    insert into backup_dba_tab_privs (
        grantee, owner, table_name, grantor, privilege, grantable, hierarchy, common, type, label)
    select grantee, owner, table_name, grantor, privilege, grantable, hierarchy, common, type, v_label
      from dba_tab_privs
     where grantee not in ('SYS', 'SYSTEM', 'ADMIN', 'OCI_SDK_ROLE', 'DWROLE', 'GGADMIN', 'DATAPUMP_CLOUD_EXP', 'ORDS_METADATA', 'DATAPUMP_CLOUD_IMP', 'OML$METADATA')
       and grantee = nvl(p_username, grantee);
    
    insert into backup_dba_sys_privs (
        grantee, privilege, admin_option, common, inherited, label)
    select grantee, privilege, admin_option, common, inherited, v_label
      from dba_sys_privs
     where grantee not in ('SYS', 'SYSTEM', 'ADMIN', 'OCI_SDK_ROLE', 'DWROLE', 'GGADMIN', 'DATAPUMP_CLOUD_EXP', 'ORDS_METADATA', 'DATAPUMP_CLOUD_IMP', 'OML$METADATA')
       and grantee = nvl(p_username, grantee);

    insert into backup_dba_role_privs (
        grantee, granted_role, admin_option, delegate_option, default_role, common, inherited, label)
    select grantee, granted_role, admin_option, delegate_option, default_role, common, inherited, v_label
      from dba_role_privs
     where grantee not in ('SYS', 'SYSTEM', 'ADMIN', 'OCI_SDK_ROLE', 'DWROLE', 'GGADMIN', 'DATAPUMP_CLOUD_EXP', 'ORDS_METADATA', 'DATAPUMP_CLOUD_IMP', 'OML$METADATA')
       and grantee = nvl(p_username, grantee);

end;
/

-- exec drop_procedure('purge_backup_privs');
create or replace procedure purge_backup_privs (
    p_date in date,
    p_label in varchar2 default null
    ) is 
begin
    delete from backup_dba_tab_privs where created < p_date and label=nvl(p_label, label);
    delete from backup_dba_sys_privs where created < p_date and label=nvl(p_label, label);
    delete from backup_dba_role_privs where created < p_date and label=nvl(p_label, label);
end;
/

declare
   n number;
begin
   select count(*) into n from backup_dba_tab_privs;
   if n = 0 then 
      backup_privs(p_label=>'initial');
   end if;
end;
/

/*

select 'grant ' || privilege || ' on ' || owner || '.' || table_name || ' to ' || grantee ||
       case 
           when grantable = 'yes' then ' with grant option' 
           else '' 
       end || ';' as grant_statement
from backup_dba_tab_privs
where label = :label 
  and grantee = :username;

select 'grant ' || privilege || ' to ' || grantee ||
       case 
           when admin_option = 'yes' then ' with admin option' 
           else '' 
       end || ';' as grant_statement
from backup_dba_sys_privs
where label = :label 
  and grantee = :username;
  
select 'grant ' || granted_role || ' to ' || grantee ||
       case 
           when admin_option = 'yes' then ' with admin option' 
           else '' 
       end || 
       case 
           when delegate_option = 'yes' then ' with delegate option' 
           else '' 
       end || ';' as grant_statement
from backup_dba_role_privs
where label = :label 
  and grantee = :username;

*/
