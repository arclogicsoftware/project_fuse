col test_id format a20
col test_time format a20
col test format a30
col test_order format 999
col value format 9999999999.9

set lines 120

select * from results order by test_id, test_order;
