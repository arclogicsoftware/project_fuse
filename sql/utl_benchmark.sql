create or replace package utl_benchmark is

   -- Note, to run a benchmark just call the "test" procedure or take a look and
   -- create your own. This package will create tables called "BENCHMARK", "X",
   -- and "RESULTS". Please make sure these tables do not already exist in the
   -- schema you are working in. The results of the benchmark will be stored
   -- in the RESULTS table.

   m_test_id    varchar2(100);
   m_test_order number := 0;
   m_test       varchar2(100);
   m_start      number;
   m_total      number;
   
   procedure test (p_rows in number default 100000, p_test_id in varchar2 default null);
 
end;
/


create or replace package body utl_benchmark as
procedure put_result (p_test varchar2, p_value in number);

-- ===================================================================
-- put_log
--
-- Basic logging function.
--
-- ===================================================================

procedure put_log (p_log_text in varchar2) is
   pragma autonomous_transaction;
begin
   dbms_output.put_line(p_log_text);
   put_result(substr(p_log_text, 1, 1000), 0);
exception
   when others then
      dbms_output.put_line(dbms_utility.format_error_stack);
end;

-- ===================================================================
-- table_missing
--
-- Return true if table is missing.
--
-- ===================================================================

function table_missing (p_table in varchar2) return boolean is
   n number;
begin
   select count(*) into n from user_tables
    where table_name=upper(p_table);
   if n > 0 then
      return false;
   end if;
   return true;
exception
   when others then
      put_log('table_missing: '||dbms_utility.format_error_stack);
      raise;
end;

-- ===================================================================
-- drop_table
--
-- Drop table is it is not missing.
--
-- ===================================================================

procedure drop_table (p_table in varchar2) is
   n number;
begin
   if not table_missing(p_table) then
      execute immediate 'drop table '||p_table;
   end if;
   
exception
   when others then
      put_log('drop_table :'||dbms_utility.format_error_stack);
      raise;
end;

-- ===================================================================
-- create_results_table
--
--
--
-- ===================================================================

procedure create_results_table is
begin
   execute immediate '
   create table results (
      test_id    varchar2(100),
      test_time  date,
      test       varchar2(1000),
      test_order number,
      value      number)';

    execute immediate '
       alter table results add constraint pk_results primary key (test_id, test)';
           
exception
   when others then
      dbms_output.put_line('create_results_table :'||dbms_utility.format_error_stack);
end;

-- ===================================================================
-- b
--
-- Marks the beginning of a test.
--
-- ===================================================================

procedure b (p_test in varchar2) is
begin
   m_test := upper(p_test);
   m_start := dbms_utility.get_time;
exception
   when others then
      dbms_output.put_line('b :'||dbms_utility.format_error_stack);
end;

-- ===================================================================
-- put_result
--
-- Two ways to put a row in this table, by calling "b" then "e", or 
-- using this procedure. "b" and "e" are for a test, this procedure
-- is used when you want to add an attribute like the # of rows
-- used in the test.
--
-- ===================================================================

procedure put_result (p_test varchar2, p_value in number) is
begin
   
   m_test_order := m_test_order + 1;
   
   if table_missing('RESULTS') then
      create_results_table;
   end if;

   execute immediate '
   insert into results (test_id, test_time, test, test_order, value) values
   (:a, :b, :c, :d, :e)' using m_test_id, sysdate, p_test, m_test_order, p_value;
   commit;
   
exception
   when others then
      dbms_output.put_line('put_result :'||dbms_utility.format_error_stack);
end;

-- ===================================================================
-- e
--
-- Marks the end of the current test.
--
-- ===================================================================

procedure e is
   l_total number;
begin
   m_test_order := m_test_order + 1;
   l_total := (dbms_utility.get_time-m_start)/100;
   if table_missing('RESULTS') then
      create_results_table;
   end if;

   execute immediate '
   insert into results (test_id, test_time, test, test_order, value) values
   (:a, :b, :c, :d, :e)' using m_test_id, sysdate, m_test, m_test_order, l_total;
   commit;
   
   m_total := m_total + l_total;
   
exception
   when others then
      dbms_output.put_line('e :'||dbms_utility.format_error_stack);
end;

-- ===================================================================
-- create_table
--
-- Create the primary table used for the benchmark.
--
-- ===================================================================

procedure create_table (p_table in varchar2 default 'BENCHMARK') is
begin
   if table_missing(p_table) then
        execute immediate '
        create table '||p_table||' as
          select rownum id, owner, table_name, column_name, data_type, data_length, nullable, column_id
            from all_tab_columns where 1 = 0';
        execute immediate '
           alter table '||p_table||' add constraint pk_'||p_table||' primary key (id)';
   end if;
exception
   when others then
      put_log('create_table :'||dbms_utility.format_error_stack);
      raise;
end;

-- ===================================================================
-- gather_stats
--
-- Gather table and index stats for a table.
--
-- ===================================================================
procedure gather_stats (p_table in varchar2) is
begin
   dbms_stats.gather_table_stats(ownname=>user,tabname=>p_table,cascade=>true);
exception
   when others then
      put_log('gather_stats :'||dbms_utility.format_error_stack);
      raise;
end;
 
-- ===================================================================
-- ugly_loop
--
-- The purpose of this loop is to chew up as much CPU as possible.
-- The faster the CPU the less time that will be spent completing this
-- loop. This is a simple way to compare CPU speed from one server to 
-- another.
--
-- ===================================================================
procedure ugly_loop (p_count in number default 20000000) is
   n number := 0;
begin
   
   put_result('UGLY LOOP COUNT', p_count);
   
   while n < p_count loop
      n := n + 1;
   end loop;
   
exception
   when others then
      put_log('gather_stats :'||dbms_utility.format_error_stack);
      raise;
end;

-- ===================================================================
-- insert_append
--
-- Create the primary test table and populate it with rows.
--
-- ===================================================================

procedure insert_append (p_rows in number default 1000000) is
   l_rowcount  number := 0;
   l_id        number := 0;
   n           number(12,2);
begin

   if table_missing('BENCHMARK') then
      create_table('BENCHMARK');
   end if;
   
   execute immediate 'select nvl(max(id), 0) from benchmark' into l_id;
     
   execute immediate 'alter table benchmark nologging';
   
   b('INSERT APPEND');
   while (l_rowcount < p_rows)
   loop
      execute immediate 
      'insert /*+ append */
        into benchmark (select rownum+'||l_id||',owner,table_name,column_name,data_type,data_length,nullable,column_id
                          from all_tab_columns where rownum <= :x - :y)' using p_rows, l_rowcount;
      l_rowcount := l_rowcount + sql%rowcount; 
      l_id := l_id + sql%rowcount;
      commit;
    end loop;
    e;
    
    execute immediate 'alter table benchmark logging';
    
    select sum(bytes)/1024/1024 into n
          from user_segments 
         where segment_type='TABLE'
           and segment_name='BENCHMARK';
    put_result('TABLE SIZE MB',n);
    
    b('GATHER STATS');
    gather_stats('BENCHMARK');
    e;

exception
   when others then
      put_log('insert_append :'||dbms_utility.format_error_stack);
      raise;
end;


procedure test (p_rows in number, p_test_id in varchar2 default null) is
begin

   m_total      := 0;
   m_test_order := 0;
   
   if p_test_id is null then
      m_test_id := to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS');
   else
      m_test_id := p_test_id;
   end if;
   
   drop_table('BENCHMARK');
   drop_table('X');
   
   insert_append(p_rows);
   
   put_result('ROW COUNT',p_rows);
   
   -- Create a copy of the primary benchmark table using NOLOGGING option.
   b('CREATE TABLE LOGGING');
   execute immediate 'create table x as (select * from benchmark)';
   e;
   
   -- Update a column for all rows in the table.
   b('SIMPLE UPDATE');
   execute immediate 'update x set data_type=to_char(sysdate, ''YYYYDDMMHH24MISS'')';
   e;
   
   -- Add a numeric column with a default value.
   b('ADD NUMBER COLUMN');
   execute immediate 'alter table x add (foo1 number default 999999)';
   e;
   
   -- Add a character column with a default value.
   b('ADD VARCHAR2(100) COLUMN');
   execute immediate 'alter table x add (foo2 varchar2(100) default '''||rpad('X', 100, 'X')||''')';
   e;
   
   -- Drop the numeric column.
   b('DROP NUMBER COLUMN');
   execute immediate 'alter table x drop column foo1';
   e;
   
   -- Drop the character column.
   b('DROP VARCHAR2(100) COLUMN');
   execute immediate 'alter table x drop column foo2';
   e;
   
   -- Delete all of the rows from the table.
   b('SIMPLE DELETE');
   execute immediate 'delete from x';
   e;
   
   execute immediate 'drop table x';
   
   -- Create a copy of the primary benchmark table using NOLOGGING option.
   b('CREATE TABLE NOLOGGING');
   execute immediate 'create table x nologging as (select * from benchmark)';
   e;
   
   -- Truncate the table.
   b('TRUNCATE TABLE');
   execute immediate 'truncate table x';
   e;
   
   execute immediate 'drop table x';
   
   -- Drop the table.
   b('DROP TABLE');
   execute immediate 'drop table benchmark';
   e;
   
   -- Chew up CPU and see how fast we can complete a pointless loop.
   b('UGLY LOOP');
   ugly_loop(20000000);
   e;
   
   put_result('TOTAL TIME', m_total);
   
exception
   when others then
      dbms_output.put_line('test :'||dbms_utility.format_error_stack);
end;

end;
/

