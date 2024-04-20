cat ./app/app_patch.sql
echo ""
cat ./app/arcsql.sql
echo ""
cat ./app/app_schema.sql
echo ""
cat ./app/app_config.sql
echo ""
cat ./app/app_views.sql
echo ""
cat ./app/app_triggers.sql
echo ""
cat ./app/stat_table_before_update.sql
echo ""
cat ./app/collect_stat_pkgh.sql
echo ""
cat ./app/collect_stat_pkgb.sql
echo ""
cat ./app/app_alert_procs.sql
echo ""
cat ./app/app_alert_pkgh.sql
echo ""
cat ./app/app_alert_pkgb.sql
echo ""
cat ./app/sql_monitor_pkgh.sql
echo ""
cat ./app/sql_monitor_pkgb.sql
echo ""
cat ./app/sensor_pkgh.sql 
echo ""
cat ./app/sensor_pkgb.sql 
echo ""
cat ./app/assert_pkgh.sql
echo ""
cat ./app/assert_pkgb.sql
echo ""
cat ./app/app_procs.sql
echo ""
cat ./app/update_object_size_data_proc.sql
echo ""
cat ./app/more_stat_stuff.sql
echo ""
cd stat
ls | grep "^stat__.*sql$" | while read f; do
   echo ""
   cat $f
done
cd ..
echo ""
cat ./sql/accounts_of_interest_view.sql
echo ""
cat ./sql/sort_info_view.sql
echo ""
cat ./sql/all_sorts_view.sql
echo ""
cat ./sql/archive_log_dist_view.sql
echo ""
cat ./sql/lockers_view.sql
echo ""
cat ./sql/asm_views.sql
echo ""
cat ./sql/tsinfo_view.sql
echo ""
cat ./sql/table_size_summary_view.sql
echo ""
cat ./sql/resource_limit_view.sql
echo ""
cat ./sql/process_limit_view.sql
echo ""
cat ./sql/unq_jobs_failing_in_last_24hr.sql
echo ""
cat ./sql/locked_objects_view.sql
echo ""
cat ./sql/table_stats_view.sql
echo ""
cat ./sql/large_sorts_view.sql
echo ""
cat ./sql/recycle_bin_info_view.sql
echo ""
cat ./sql/rman_backup_job_details_view.sql
echo ""
cat ./sql/rman_status_view.sql
echo ""
cat ./sql/create_table_dist_view.sql
echo ""
cat ./sql/instance_uptime_view.sql
echo ""
cat ./sql/arch_dest_status_time_view.sql
echo ""
cat ./sql/blocked_sessions_view.sql
echo ""
cat ./sql/active_sorts_view.sql
echo ""
cat ./sql/session_info_view.sql 
echo ""
cat ./sql/sga_info_view.sql 
echo ""
cat ./sql/jde_run_batch_views.sql
echo ""
cat ./sql/standby_completion_time_views.sql
echo ""
cat ./sql/table_growth_rates_view.sql
echo ""
cat ./sql/unified_audit_review_view.sql
echo ""
cd alert
ls | grep "^alert__.*sql$" | while read f; do
   echo ""
   cat $f
done
cd ..
echo ""
cd sensor
ls | grep "^sensor__.*sql$" | while read f; do
   echo ""
   cat $f
done
cd ..
echo ""
cd prc
ls | grep "\.sql$" | egrep -v "install_prc\.sql" | while read f; do
   echo ""
   cat $f
done
cd ..
echo ""
cat ./app/app_synonyms.sql 
echo ""
cat ./app/app_schedules.sql
echo ""
cat ./app/app_tests.sql
echo ""