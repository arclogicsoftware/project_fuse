exec drop_procedure('execute_sql');

exec drop_procedure('TS_TEST_SCHED');

-- 7/9/2024 Switch to timestamp for epoch and need to purge cache so changed name of the key.
-- Let's get rid of the old keys.
delete from cache_table where cache_key like 'alert__%next_check';
commit;
