
create or replace package app_config as 
   function param_exists (p_name in varchar2) return boolean;
   procedure set_param_str(p_name in varchar2, p_str in varchar2); 
   procedure set_param_num(p_name in varchar2, p_num in number); 
   procedure add_param_str(p_name in varchar2, p_str in varchar2); 
   procedure add_param_num(p_name in varchar2, p_num in number); 
   function get_param_num(p_name in varchar2, p_default in number default null) return number; 
   function get_param_str(p_name in varchar2, p_default in varchar2 default null) return varchar2; 
   procedure del_param(p_name in varchar2);
end;
/

create or replace package body app_config as 

function param_exists (p_name in varchar2) return boolean is 
   n number;
begin
   select count(*) into n from config_table where lower(name)=lower(p_name);
   return n=1;
end;

procedure set_param_str(p_name in varchar2, p_str in varchar2) is 
begin 
   update config_table set value=p_str where lower(name)=lower(p_name);
end;

procedure set_param_num(p_name in varchar2, p_num in number) is 
begin 
   update config_table set value=to_char(p_num) where lower(name)=lower(p_name);
end;

procedure add_param_str(p_name in varchar2, p_str in varchar2) is 
begin
   if not param_exists(p_name) then 
      insert into config_table (name, value, is_numeric) values (lower(p_name), p_str, 0);
   end if;
end;

procedure add_param_num(p_name in varchar2, p_num in number) is 
begin
   if not param_exists(p_name=>p_name) then 
      insert into config_table (name, value, is_numeric) values (lower(p_name), to_char(p_num), 1);
   end if;
end;

function get_param_num(p_name in varchar2, p_default in number default null) return number is 
   n number;
begin 
   if param_exists(p_name=>p_name) then 
      select to_number(value) into n from config_table where lower(name)=p_name;
      return n;
   else 
      return p_default;
   end if;
end;

function get_param_str(p_name in varchar2, p_default in varchar2 default null) return varchar2 is 
   v config_table.value%type;
begin 
   if param_exists(p_name) then 
      select value into v from config_table where lower(name)=p_name;
      return v;
   else 
      return p_default;
   end if;
end;

procedure del_param(p_name in varchar2) is 
begin
   delete from config_table where name=p_name;
   commit;
end;

end;
/

-- ToDo: Do these need to be here, they are duplicates of app_install.sql file.
begin 
   app_config.add_param_num(p_name=>'collect_stat_repeat_interval', p_num=>5);
   app_config.add_param_num(p_name=>'monitor_sql_repeat_interval', p_num=>15);
   app_config.add_param_num(p_name=>'small_table_gb_limit', p_num=>.1);
   app_config.add_param_num(p_name=>'object_size_data_min_mb', p_num=>100);
   app_config.add_param_num(p_name=>'collect_table_sizes_repeat_interval', p_num=>300);
   -- Suggestions 'non' or 'prd'.
   app_config.add_param_str(p_name=>'env', p_str=>'prd');
end;
/

