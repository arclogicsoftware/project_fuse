declare
   n number;
begin
   init_test('Fails when there are any offline datafiles', 'database');
   select count(*) into n from gv$datafile where status not in ('ONLINE', 'SYSTEM');
   if n = 0 then
      pass_test;
    end if;
end;
/