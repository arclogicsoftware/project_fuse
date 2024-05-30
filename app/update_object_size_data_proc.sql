create or replace procedure update_object_size_data is 
   cursor c_segments (l_minsize number) is
     select owner,
            segment_name,
            segment_type,
            partition_name,
            tablespace_name,
            round(bytes/1048576) megabytes
       from dba_segments
      where segment_type in ('TABLE','INDEX')
        and bytes >= l_minsize*1048576
      union
        all 
     select owner,
            tablespace_name||' Objects < '||l_minsize||'M',
            segment_type,
            partition_name,
            tablespace_name,
            round(sum(bytes)/1048576) megabytes
       from dba_segments
      where segment_type in ('TABLE','INDEX')
        and bytes < l_minsize*1048576
      group
         by owner,
       tablespace_name||' Objects < '||l_minsize||'M',
            segment_type,
            partition_name,
            tablespace_name
    union all 
     select 'SYS' owner,
            file_name segment_name,
            'datafile' segment_type,
            null partition_name,
            null tablespace_name,
            round(bytes/1048576) megabytes
       from dba_data_files
    union all 
     select 'SYS' owner,
            file_name segment_name,
            'tempfile' segment_type,
            null partition_name,
            null tablespace_name,
            round(bytes/1048576) megabytes
       from dba_temp_files
    union all
     select 'SYS' owner,
            'inst_id='||inst_id||' group#='||group# segment_name,
            'redolog' segment_type,
            null partition_name,
            null tablespace_name,
            round(bytes/1048576) megabytes
       from gv$log;
   
   l_record        obj_size_data%rowtype;
   l_mth           number;
   l_new_record    boolean;
   l_updated       date := sysdate;
   l_first_time    boolean;
   l_num           number;
   l_year          number := to_number(to_char(sysdate,'YYYY'));
   l_obj_size      number := app_config.get_param_num('object_size_data_min_mb', 100);

begin

   for x in c_segments(l_obj_size) loop

      l_new_record := false;

          begin
             select *
               into l_record
               from obj_size_data
              where owner = x.owner
                and segment_name = x.segment_name
                and partition_name = NVL(x.partition_name, 'NULL')
                and segment_type = x.segment_type
                and year = l_year
            for update;
          exception
             when no_data_found then
                l_new_record := true;
             when others then
                dbms_output.put_line(dbms_utility.format_error_stack);
          end;

      if l_new_record then
         begin
            insert into obj_size_data (
              owner,
              segment_name,
              partition_name,
              segment_type,
              tablespace_name,
              start_size,
              last_size,
              updated)
               values
             (x.owner,
              x.segment_name,
              nvl(x.partition_name, 'NULL'),
              x.segment_type,
              x.tablespace_name,
              x.megabytes,
              x.megabytes,
              l_updated);
         exception
          when others then 
              dbms_output.put_line(x.segment_name|| ' ' ||x.tablespace_name);
         end;
      else

         l_first_time := false;
         if trunc(sysdate, 'MONTH') <> trunc(l_record.updated, 'MONTH') then
            l_first_time := true;
         end if;

         l_mth := to_number(to_char(sysdate, 'MM'));
         if l_mth = 1 then
            l_num := l_record.jan;
            if l_first_time then
                l_num := 0;
            end if;
            l_record.jan := l_num + x.megabytes - l_record.last_size;
         elsif l_mth = 2 then
            l_num := l_record.feb;
            if l_first_time then
                l_num := 0;
            end if;
            l_record.feb := l_num + x.megabytes - l_record.last_size;
         elsif l_mth = 3 then
            l_num := l_record.mar;
            if l_first_time then
                l_num := 0;
            end if;
            l_record.mar := l_num + x.megabytes - l_record.last_size;
         elsif l_mth = 4 then
            l_num := l_record.apr;
            if l_first_time then
                l_num := 0;
            end if;
            l_record.apr := l_num + x.megabytes - l_record.last_size;
         elsif l_mth = 5 then
            l_num := l_record.may;
            if l_first_time then
                l_num := 0;
            end if;
            l_record.may := l_num + x.megabytes - l_record.last_size;
         elsif l_mth = 6 then
            l_num := l_record.jun;
            if l_first_time then
                l_num := 0;
            end if;
            l_record.jun := l_num + x.megabytes - l_record.last_size;
         elsif l_mth = 7 then
            l_num := l_record.jul;
            if l_first_time then
                l_num := 0;
            end if;
            l_record.jul := l_num + x.megabytes - l_record.last_size;
         elsif l_mth = 8 then
            l_num := l_record.aug;
            if l_first_time then
                l_num := 0;
            end if;
            l_record.aug := l_num + x.megabytes - l_record.last_size;
         elsif l_mth = 9 then
            l_num := l_record.sep;
            if l_first_time then
                l_num := 0;
            end if;
            l_record.sep := l_num + x.megabytes - l_record.last_size;
         elsif l_mth = 10 then
            l_num := l_record.oct;
            if l_first_time then
                l_num := 0;
            end if;
            l_record.oct := l_num + x.megabytes - l_record.last_size;
         elsif l_mth = 11 then
            l_num := l_record.nov;
            if l_first_time then
                l_num := 0;
            end if;
            l_record.nov := l_num + x.megabytes - l_record.last_size;
             elsif l_mth = 12 then
            l_num := l_record.dec;
            if l_first_time then
                l_num := 0;
            end if;
            l_record.dec := l_num + x.megabytes - l_record.last_size;
         end if;

         update obj_size_data
             set
                last_size = x.megabytes,
                last_delta = x.megabytes - l_record.last_size,
                jan = l_record.jan,
                feb = l_record.feb,
                mar = l_record.mar,
                apr = l_record.apr,
                may = l_record.may,
                jun = l_record.jun,
                jul = l_record.jul,
                aug = l_record.aug,
                sep = l_record.sep,
                oct = l_record.oct,
                nov = l_record.nov,
                dec = l_record.dec,
                updated = l_updated,
      tablespace_name=x.tablespace_name
          where owner = x.owner
            and segment_name = x.segment_name
            and partition_name = nvl(x.partition_name, 'NULL')
            and segment_type = x.segment_type
            and year = l_year;

      end if;

   end loop;

   delete from obj_size_data where updated < sysdate-90 and year=l_year;

   commit;

exception
   when others then
      raise;
end;
/