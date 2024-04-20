

create or replace procedure execute_select (
	p_sql in varchar2) is 
   c clob;
begin
   c := sql_to_csv_clob(p_sql);
   fuse.user(c);
end;
/

