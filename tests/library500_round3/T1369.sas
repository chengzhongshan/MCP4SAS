/* T1369 datetime_components, N=10; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data t1369o; stamp=input('01JAN2012:12:34:56',datetime20.); actual=datepart(stamp)+timepart(stamp); run;

data _null_; if 0 then set t1369o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1369 rows=' rows;
else do; set t1369o; if not missing(actual) and abs(actual-(64289))<=1e-10*max(1,abs(64289)) then put 'ROUND3_PASS=T1369';
else put 'ERROR: ROUND3_FAIL=T1369 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1369:; quit;
