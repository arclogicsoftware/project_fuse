set lines 250
set pages 100

column owner format a15 trunc
column segment_name format a15 trunc 
column tablespace_name format a20 trunc
column year format 9999 heading "Year"
column jan format 99999
column feb format 99999
column mar format 99999
column apr format 99999
column may format 99999
column jun format 99999
column jul format 99999
column aug format 99999
column sep format 99999
column oct format 99999
column nov format 99999
column dec format 99999
column total format 999999

select tablespace_name,
       year,
       sum(jan) jan,
       sum(feb) feb,
       sum(mar) mar,
       sum(apr) apr,
       sum(may) may,
       sum(jun) jun,
       sum(jul) jul,
       sum(aug) aug,
       sum(sep) sep,
       sum(oct) oct,
       sum(nov) nov,
       sum(dec) dec,
       sum(jan + feb + mar + apr + may + jun + jul + aug + sep + oct + nov + dec) total
  from obj_size_data
 group
    by tablespace_name,
       year
having sum(jan + feb + mar + apr + may + jun + jul + aug + sep + oct + nov + dec) > 0
 order
    by 15;

