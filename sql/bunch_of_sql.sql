SELECT
    (SELECT SUM(bytes/1024/1024/1024) FROM dba_segments) AS "Segments (gb)",
    (SELECT SUM(bytes/1024/1024/1024) FROM v$log) AS "Redo Logs (gb)",
    (SELECT SUM(bytes/1024/1024/1024) FROM v$datafile) AS "Data Files (gb)",
    (SELECT SUM(bytes * 8)/1024/1024/1024 FROM v$tempfile) AS "Temp Files (gb)",
    (SELECT SUM(bytes * 8)/1024/1024/1024 FROM v$controlfile) AS "Control Files (gb)"
FROM
    dual;

select * from v$flash_recovery_area_usage;

select * from v$recovery_area_usage;

select name, value from v$parameter where name = 'db_recovery_file_dest';

select name, value from v$parameter where name = 'db_recovery_file_dest_size';

select name, free_mb, total_mb, free_mb/total_mb*100 as percentage from v$asm_diskgroup;

col gname form a10
col dbname form a10
col file_type form a14

select
    gname,
    dbname,
    file_type,
    round(SUM(space)/1024/1024) mb,
    round(SUM(space)/1024/1024/1024) gb,
    count(*) "#FILES"
from
    (
        select
            gname,
            regexp_substr(full_alias_path, '[[:alnum:]_]*',1,4) dbname,
            file_type,
            space,
            aname,
            system_created,
            alias_directory
        FROM
            (
                select
                    concat('+'||gname, sys_connect_by_path(aname, '/')) full_alias_path,
                    system_created,
                    alias_directory,
                    file_type,
                    space,
                    level,
                    gname,
                    aname
                FROM
                    (
                        select
                            b.name            gname,
                            a.parent_index    pindex,
                            a.name            aname,
                            a.reference_index rindex ,
                            a.system_created,
                            a.alias_directory,
                            c.type file_type,
                            c.space
                        FROM
                            v$asm_alias a,
                            v$asm_diskgroup b,
                            v$asm_file c
                        WHERE
                            a.group_number = b.group_number
                        AND a.group_number = c.group_number(+)
                        AND a.file_number = c.file_number(+)
                        AND a.file_incarnation = c.incarnation(+) ) START WITH (mod(pindex, power(2, 24))) = 0
                AND rindex IN
                    (
                        select
                            a.reference_index
                        FROM
                            v$asm_alias a,
                            v$asm_diskgroup b
                        WHERE
                            a.group_number = b.group_number
                        AND (
                                mod(a.parent_index, power(2, 24))) = 0
                            and a.name like '&&db_name'
                    ) CONNECT BY prior rindex = pindex )
        WHERE
            NOT file_type IS NULL
            and system_created = 'Y' )
WHERE
    dbname like '&db_name'
GROUP BY
    gname,
    dbname,
    file_type
ORDER BY
    gname,
    dbname,
    file_type
/


select name,
  (space_limit / 1024 / 1024 / 1024) space_limit_gb,
  ((space_limit - space_used + space_reclaimable) / 1024 / 1024 / 1024) as space_available_gb,
  round((space_used - space_reclaimable) / space_limit * 100, 1) as percent_full
  from v$recovery_file_dest;  



