
delete from tool_group where tool_group_name='oracle_tools';

begin
   fuse.add_tool_group (
      p_tool_group=>'oracle_tools',
      p_desc=>'Basic Oracle tooling for Fuse.');
end;
/

create or replace procedure list_all_db_users as 
begin
   fuse.tool_response := convert_to_csv_row('select username from dba_users');
end;
/

begin
   fuse.add_tool (
      p_tool_group=>'oracle_tools',
      p_function_name=>'list_all_db_users',
      p_function_desc=>'Returns a comma delimited list of all database user accounts.');
end;
/

create or replace procedure get_row_count_from_table (p_table_name in varchar2) is 
begin
   execute immediate 'select count(*) from '||p_table_name into fuse.tool_response;
end;
/

begin
   fuse.add_tool (
      p_tool_group=>'oracle_tools',
      p_function_name=>'get_row_count_from_table',
      p_function_desc=>'Return the number of rows from the specified table or view.',
      p_arg1=>'p_table_name',
      p_arg1_type=>'string',
      p_arg1_desc=>'The name of the table or view.');
end;
/

create or replace procedure lock_user_account (p_user_name in varchar2) is 
begin 
   debug('lock_user_account: '||p_user_name);
   execute immediate 'alter user '||p_user_name||' account lock';
end;
/

begin
   fuse.add_tool (
      p_tool_group=>'oracle_tools',
      p_function_name=>'lock_user_account',
      p_function_desc=>'Locks the account of the specified user.',
      p_arg1=>'p_user_name',
      p_arg1_type=>'string',
      p_arg1_desc=>'The name of the user account to lock.');
end;
/
