create or replace view sensor__data_files as
select file_name name,
       online_status value 
  from dba_data_files;