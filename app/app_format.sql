create or replace package app_format as 
   
   t_row clob;
   t_header varchar2(4000) default '';
   t_header_base varchar2(4000) default '';
   t_row_num number default 0;
   t_table clob;

   procedure init_table;
   procedure add_value_to_table (
      p_row_num in number, 
      p_col_name in varchar2, 
      p_col_size in number,
      p_col_value in varchar2);
   function get_table return clob;

end;
/

create or replace package body app_format as 

procedure init_table is 
begin
   app_format.t_row := '|';
   app_format.t_header := '|';
   app_format.t_header_base := '|';
   app_format.t_row_num := 0;
   app_format.t_table := '';
end;

procedure add_value_to_table (
   p_row_num in number, 
   p_col_name in varchar2, 
   p_col_size in number,
   p_col_value in varchar2) is
begin
   if p_row_num = 1 then
      t_row_num := 1;
      t_header := t_header || rpad(substr(p_col_name, 1, p_col_size), p_col_size) || '|';
      t_header_base := t_header_base || rpad('-', p_col_size, '-') || '|';
   end if;
   if p_row_num != t_row_num then 
      t_table := t_table || t_row || chr(10);
      t_row := '|';
      t_row_num := p_row_num;
   end if;
   t_row := t_row || rpad(substr(p_col_value, 1, p_col_size), p_col_size) || '|';
end;

function get_table return clob is 
begin
   t_table := t_header || chr(10) || t_header_base || chr(10) || t_table;
   t_table := t_table || t_row || chr(10);
   return t_table;
end;

end;
/

-- begin
--    app_format.init_table;
--    app_format.add_value_to_table(1, 'Name', 20, 'John');
--    app_format.add_value_to_table(1, 'Age', 20, '32');
-- --   app_format.add_value_to_table(2, 'Name', 20, 'Jane');
-- --   app_format.add_value_to_table(2, 'Age', 20, '31');
--    dbms_output.put_line(app_format.get_table);
-- end;
-- /

