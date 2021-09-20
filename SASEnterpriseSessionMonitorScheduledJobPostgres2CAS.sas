/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* SAS Enterprise Session Monitor */
/* Schedule this code to run every day */
/* Reads the agent data in Postgres and loads it into CAS */
/* For this code to work create a global CASLIB called ESM */

%let timezone = 'UTC';

libname pgesm postgres server='dsn' port=15432 user=userid password=userid database=esm;

cas;
caslib _all_ assign;

PROC DELETE data=esm._all_;
run;

/* Day of Week user defined format */
proc format casfmtlib="casformats";
              value dow
              1 = 'Sunday'
              2 = 'Monday'
              3 = 'Tuesday'
              4 = 'Wednesday'
              5 = 'Thursday'
              6 = 'Friday'
              7 = 'Saturday';
run;

cas casauto savefmtlib fmtlibname=casformats table=dow replace;
cas casauto promotefmtlib fmtlibname='casformats' replace;
cas casauto listfmtranges fmtname=dow;

data esm_jobs;
              
              set pgesm.esm_job;
              from_date = tzoneu2s(from_date, &timezone.);
              to_date = tzoneu2s(to_date, &timezone.);
              save=flow;
              x=count(flow,":");
              if x ge 1 then
                             do;
                                           flow=scan(save, 1, ':');
                                           subflow=scan(save, 2, ':');
                             end;
              if x ge 2 then
                             do;
                                           subsubflow=scan(save, 3, ':');
                             end;
              if x ge 3 then
                             do;
                                           subsubsubflow=scan(save, 3, ':');
                             end;
              drop save x;

              runtime_seconds=intck('sec',from_date,to_date);
              runtime_minutes=runtime_seconds/60.0;
              runtime_hours=runtime_minutes/60.0;
              format dayofweekn dow.;
              dayofweekn=weekday(datepart(from_date));
              dayofmonth=day(datepart(from_date));
              format time time.;
              time=timepart(from_date);
              hour=hour(time);

              kilobytes_read = total_bytes_read/1024;
              megabytes_read = kilobytes_read/1024;
              gigabytes_read = megabytes_read/1024;
              terabytes_read = gigabytes_read/1024;
              
              kilobytes_written = total_bytes_written/1024;
              megabytes_written = kilobytes_written/1024;
              gigabytes_written = megabytes_written/1024;
              terabytes_written = gigabytes_written/1024;
run;

proc sql;
              create table esm_jobs_nodes as 
                             select a.*, b.esm_group
                             from esm_jobs as a
                             join pgesm.esm_node as b on a.hostname = b.hostname
              ;
quit;

data esm.esm_jobs(replace=yes compress=yes copies=0 promote=yes compress=yes copies=0 promote=yes);
              set esm_jobs_nodes;
run;

proc sql;
              create table tempflows as
                             select flow, subflow, subsubflow, day, min(from_date) format=datetime. as from_date, max(to_date) format=datetime. as to_date
                             from (

                                           select flow, subflow, subsubflow, datepart(from_date) format=date. as day, min(from_date) format=datetime20. as from_date, max(to_date) format=datetime20. as to_date
                                           from esm_jobs
                                           group by flow, subflow, subsubflow, day
                             )
                             group by flow, subflow, subsubflow, day
              ;
quit;

/* data esm.flow_stages(replace=yes compress=yes copies=0 promote=yes); */
/*           set tempflows; */
/*           elapsed_seconds=intck('sec',from_date,to_date); */
/*           elapsed_minutes=elapsed_seconds/60.0; */
/*           elapsed_hours=elapsed_minutes/60.0; */
/*           dayofweekn=weekday(datepart(from_date)); */
/*           dayofmonth=day(datepart(from_date)); */
/*           format time time.; */
/*           time=timepart(from_date); */
/*           hour=hour(time); */
/* run; */

data server_statistics_a;
              set pgesm.esm_servers_stats_agg_min;
              time_stamp = tzoneu2s(time_stamp, &timezone.);
              format dayofweekn dow.;
              dayofweekn=weekday(datepart(time_stamp));
              dayofmonth=day(datepart(time_stamp));
              format time time.;
              time=timepart(time_stamp);
              hour=hour(time);
run;

proc sql;
   create table  server_statistics as 
   select a.*, b.esm_group
   from server_statistics_a as a
   join pgesm.esm_node as b on a.hostname = b.hostname;
quit;

data esm.server_statistics(compress=yes copies=0 promote=yes);
   set server_statistics;
run;

data esm.server_statistics_hour(compress=yes copies=0 promote=yes);
              set pgesm.esm_servers_stats_agg_hour;
              time_stamp = tzoneu2s(time_stamp, &timezone.);
              format dayofweekn dow.;
              dayofweekn=weekday(datepart(time_stamp));
              dayofmonth=day(datepart(time_stamp));
              format time time.;
              time=timepart(time_stamp);
              hour=hour(time);
run;

/*concurrent sessions*/
proc sql;
    create table c1 as
        select time_stamp as ts, esm_type, esm_user, a.hostname, esm_group
        from pgesm.esm_process_stats_agg_hour as a 
                             join pgesm.esm_node as b on a.hostname = b.hostname
        where esm_type in ('WS', 'CMP', 'SPRE', 'Foundation', 'CS', 'Batch','CASW', 'CASC','GRID','python', 'R','STP','PWS')
              ;
              create table concurrent_sessions as
                  select ts, esm_type, esm_user, esm_group,
                             case
                                           when count(*) < 2 then 0
                                           else count(*)
                             end as concurrent_sessions
                  from c1
                  group by ts, esm_type, esm_user, esm_group
                  order by 2,3,1
              ;
quit;

data esm.concurrent_sessions(compress=yes copies=0 promote=yes);
              set concurrent_sessions;
              ts = tzoneu2s(ts, &timezone.);
              dayofweekn=weekday(datepart(ts));
              dayofmonth=day(datepart(ts));
              format time time.;
              time=timepart(ts);
              hour=hour(time);
run;


proc sql;
    create table tempsess as
        select a.*, b.esm_group
        from pgesm.esm_session as a
                             join pgesm.esm_node  as b on a.hostname = b.hostname
              ;

quit;

proc sql ;
      create table temp1 as 
           select 
                  session_id,
                   max(sys_cpu) as sys_cpu,
                   max(user_cpu) as user_cpu
                                          
      from pgesm.esm_process_stats_agg_min as a
          group by session_id

              ;             

              create table temp2 as    
                             select *, divide(sys_cpu,user_cpu) as sys_cpu_pct
                             from temp1
              ;

              create table sessions as
                             select a.*,b.sys_cpu_pct
                             from tempsess as a
                             left join temp2 as b on a.id = b.session_id
              ;

quit;

data esm.sessions (compress=yes copies=0 promote=yes);
              set sessions;
              format dayofweekn dow.;
              dayofweekn=weekday(datepart(start_time));
              dayofmonth=day(datepart(start_time));
              format time time.;
              time=timepart(start_time);
              hour=hour(time);
              kilobytes_read = total_bytes_read/1024;
              megabytes_read = kilobytes_read/1024;
              gigabytes_read = megabytes_read/1024;
              terabytes_read = gigabytes_read/1024;
              
              kilobytes_written = total_bytes_written/1024;
              megabytes_written = kilobytes_written/1024;
              gigabytes_written = megabytes_written/1024;
              terabytes_written = gigabytes_written/1024;
              runtime_seconds=intck('sec',start_time,end_time);
              runtime_minutes=runtime_seconds/60.0;
              runtime_hours=runtime_minutes/60.0;
run;

proc means data=esm.sessions;
   by job_name esm_group;
   var avg_cpu avg_memory kilobytes_read kilobytes_written runtime_minutes sys_cpu_pct; 
   OUTPUT OUT=casuser.sessionsAVG;
run;

data esm.sessionsAVG(promote=yes compress=yes);
   set casuser.sessionsAVG (where=(_stat_ = 'MEAN'));
              if kilobytes_read = . then kilobytes_read = 0;
              if kilobytes_written = . then kilobytes_written = 0;
run;

proc means data=esm.sessions;
   var start_time;
   OUTPUT OUT=casuser.sessionsStartTime;
run;

/* proc freqtab data=casuser.sessionsStartTime; */
/*    table esm_group; */
/* run; */

data work.sessionsStartTime ;
   set casuser.sessionsStartTime (where=(_stat_ = 'MIN' or _stat_ = 'MAX'));
   retain startDay;
   date = datepart(start_time);
   if _stat_ = 'MIN' then startDay = date;
   if _stat_ = 'MAX' then stopDay = date;
   days=intck ('day',startDay,stopDay);
   call symput('days',days);
run;

data esm.sessionsDateCat(promote=yes compress=yes);
   length dateCat $12 floorID floorM floorW 8.;
   set esm.sessionsAVG;
   drop floorID floorM floorW;
   floorID = floor(&days);
   floorM = floor(&days/31);
   floorW = floor(&days/7);
   if scan(job_name,-1) = 'sas' then 
     do;
       if _freq_ > floor(&days+2) then dateCat = 'Intraday';
       else if _freq_ >= (&days-2) and _freq_ <= (&days+2) then dateCat ='Daily';
       else if _freq_ >= floor(&days/31) and _freq_ <= floor((&days/31) +2) then dateCat ='Monthly';
       else if _freq_ >= floor((&days/7) - 2)and _freq_ <= floor((&days/7) +2)  then dateCat ='Weekly';
       else if _freq_ < floor(&days/7) then dateCat = 'Infrequent';
       else dateCat='Intermittent';
     end;
run;

proc means data=esm.sessions;
   by owner esm_group;
   var peak_cpu max_work total_bytes_read total_bytes_written runtime_minutes sys_cpu_pct ; 
   OUTPUT OUT=casuser.sessionsUSERAVG;
run;

data esm.sessionsUSERMAX(promote=yes compress=yes);
   set casuser.sessionsUSERAVG (where=(_stat_ = 'MAX'));
   if total_bytes_read = . then total_bytes_read = 0;
   if total_bytes_written = . then total_bytes_written = 0;
run;

/* data esm.esm_events(drop=blanks log_file noext); */
/*           set pgesm.esm_markers(where=(text='W' or text='E')); */
/*           select(text); */
/*                         when ('E') error_code=1; */
/*                         when ('W') error_code=2; */
/*                         otherwise error_code=0; */
/*           end; */
/*           time_stamp = tzoneu2s(time_stamp, &timezone.); */
/*           dayofweekn=weekday(datepart(time_stamp)); */
/*           dayofmonth=day(datepart(time_stamp)); */
/*           format time time.; */
/*           time=timepart(time_stamp); */
/*           hour=hour(time); */
/*           blanks=countw(log_file_name, '\'); */
/*           log_file=scan(log_file_name, blanks, '\'); */
/*           noext=substr(log_file, 1, length(log_file)-24); */
/*           job_name=cats(noext,'.sas'); */
/* run; */
