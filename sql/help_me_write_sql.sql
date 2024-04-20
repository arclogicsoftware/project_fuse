DECLARE
  insert_sql VARCHAR2(8000); -- Adjust the size based on your column count
BEGIN
  -- Construct the dynamic SQL statement to insert the values into the new table
  insert_sql := 'INSERT INTO new_table (';

  -- Append column names to the insert statement
  FOR col IN (SELECT column_name FROM all_tab_columns WHERE table_name = 'F4201' and owner='PDDTA' order by column_id) LOOP
    insert_sql := insert_sql || col.column_name || ', ';
  END LOOP;

  -- Remove the trailing comma and space
  insert_sql := RTRIM(insert_sql, ', ') || ') VALUES (';

  -- Append column values to the insert statement
  FOR col IN (SELECT column_name FROM all_tab_columns WHERE table_name = 'F4201' and owner='PDDTA' order by column_id) LOOP
    insert_sql := insert_sql || ':OLD.' || col.column_name || ', ';
  END LOOP;

  -- Remove the trailing comma and space and close the parentheses
  insert_sql := RTRIM(insert_sql, ', ') || ')';
  dbms_output.put_line(insert_sql);
  -- Execute the dynamic SQL statement
  -- EXECUTE IMMEDIATE insert_sql;
END;
/
