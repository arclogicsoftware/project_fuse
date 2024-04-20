
set lines 120 feed off
column owner format a15
column directory_name format a25
column directory_path format a55
column origin_con_id format 999999

prompt "ALL_DIRECTORIES"

select * from all_directories;


