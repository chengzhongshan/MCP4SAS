/* T1366 datetime_components, N=7; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data t1366o; stamp=input('01JAN2000:12:34:56',datetime20.); actual=datepart(stamp)+timepart(stamp); run;

data _null_; if 0 then set t1366o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1366 rows=' rows;
else do; set t1366o; if not missing(actual) and abs(actual-(59906))<=1e-10*max(1,abs(59906)) then put 'ROUND3_PASS=T1366';
else put 'ERROR: ROUND3_FAIL=T1366 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1366:; quit;
