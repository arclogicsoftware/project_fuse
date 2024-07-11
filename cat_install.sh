cat ./app/app_patch.sql
echo ""
cat ./app/arcsql.sql
echo ""
cat ./app/app_schema.sql
echo ""
cat ./app/app_config.sql
echo ""
cat ./app/app_triggers.sql
echo ""
cat ./app/stat_table_before_update.sql
echo ""
cat ./app/collect_stat_pkgh.sql
echo ""
cat ./app/collect_stat_pkgb.sql
echo ""
cat ./app/app_alert.sql
echo ""
cat ./app/app_alert_pkgh.sql
echo ""
cat ./app/app_alert_pkgb.sql
echo ""
cat ./app/sql_monitor.sql
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
cd view
ls | grep "\.sql$" | egrep -v "install_views.sql" | while read f; do
   echo ""
   cat $f
done
cd ..
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
