/* T1370 datetime_components, N=11; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data t1370o; stamp=input('01JAN2016:12:34:56',datetime20.); actual=datepart(stamp)+timepart(stamp); run;

data _null_; if 0 then set t1370o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1370 rows=' rows;
else do; set t1370o; if not missing(actual) and abs(actual-(65750))<=1e-10*max(1,abs(65750)) then put 'ROUND3_PASS=T1370';
else put 'ERROR: ROUND3_FAIL=T1370 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1370:; quit;
