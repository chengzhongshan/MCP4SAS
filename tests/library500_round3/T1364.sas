/* T1364 datetime_components, N=5; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data t1364o; stamp=input('01JAN1992:12:34:56',datetime20.); actual=datepart(stamp)+timepart(stamp); run;

data _null_; if 0 then set t1364o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1364 rows=' rows;
else do; set t1364o; if not missing(actual) and abs(actual-(56984))<=1e-10*max(1,abs(56984)) then put 'ROUND3_PASS=T1364';
else put 'ERROR: ROUND3_FAIL=T1364 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1364:; quit;
