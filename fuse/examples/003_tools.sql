


select * from fuse_tool;

delete from log_table;
delete from json_data;

exec fuse.init;
exec fuse.randomness := 0;
exec fuse.create_session(p_session_name=>'oracle_tools', p_model_name=>fuse_config.default_model_name, p_tool_group=>'oracle_tools');
exec fuse.system('You are a function calling LLM that uses the data extracted from a function to answer questions and perform actions.');
exec fuse.user('How many rows are in the SQL_LOG table?');

-- Halucinates here
exec fuse.user('Are there any accounts you think should be locked?');

select * from log_table order by 1 desc;
select * from json_data order by 1 desc;
select * from session_prompt order by 1 desc;


exec drop_procedure('list_all_db_users');
exec drop_procedure('get_row_count_from_table');
