/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* SAS Enterprise Session Monitor */
/* Schedule this code to run every day */
/* Reads the agent data in Postgres and loads it into CAS */
/* For this code to work create a global CASLIB called ESM */

%let timezone = 'UTC';
 
libname pgesm postgres server='servername' port=15432 user=<userid> password=<password> database=esm;
cas;

/* Only run this code once to create the global CASLIB ESM */
/*proc cas;*/
/*   file log;*/
/*   table.dropCaslib /*/
/*   caslib="ESM" quiet = true;*/
/*run;*/
/*  addcaslib /*/
/*    datasource={srctype="path"}*/
/*    name="ESM"*/
/*    path="/path/that/all/cas/worker/nodes/and/cas/controller/have/access/to"*/
/*    session=false;*/
/* run;*/
/*quit;*/

caslib _all_ assign;
 
PROC DELETE data=esm._all_;
run;
 
 
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
 
 
data esm.server_statistics(replace=yes compress=yes copies=0 promote=yes);
                set pgesm.esm_servers_stats_agg_min;
                time_stamp = tzoneu2s(time_stamp, &timezone.);
                format dayofweekn dow.;
                dayofweekn=weekday(datepart(time_stamp));
                dayofmonth=day(datepart(time_stamp));
                format time time.;
                time=timepart(time_stamp);
                hour=hour(time);
run;
 
data esm.server_statistics_hour(replace=yes compress=yes copies=0 promote=yes);
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
 
data esm.concurrent_sessions(replace=yes compress=yes copies=0 promote=yes);
                set concurrent_sessions;
                ts = tzoneu2s(ts, &timezone.);
                dayofweekn=weekday(datepart(ts));
                dayofmonth=day(datepart(ts));
                format time time.;
                time=timepart(ts);
                hour=hour(time);
run;
 
 
proc sql;
 
    create table sessions as
        select a.*, b.esm_group
        from pgesm.esm_session as a
                                join pgesm.esm_node  as b on a.hostname = b.hostname
                ;
 
quit;
 
data esm.sessions(replace=yes compress=yes copies=0 promote=yes);
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
 
/* data esm.esm_events(drop=blanks log_file noext); */
/*            set pgesm.esm_markers(where=(text='W' or text='E')); */
/*            select(text); */
/*                            when ('E') error_code=1; */
/*                            when ('W') error_code=2; */
/*                            otherwise error_code=0; */
/*            end; */
/*            time_stamp = tzoneu2s(time_stamp, &timezone.); */
/*            dayofweekn=weekday(datepart(time_stamp)); */
/*            dayofmonth=day(datepart(time_stamp)); */
/*            format time time.; */
/*            time=timepart(time_stamp); */
/*            hour=hour(time); */
/*            blanks=countw(log_file_name, '\'); */
/*            log_file=scan(log_file_name, blanks, '\'); */
/*            noext=substr(log_file, 1, length(log_file)-24); */
/*            job_name=cats(noext,'.sas'); */
/* run; */
