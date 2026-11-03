/* T1368 datetime_components, N=9; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data t1368o; stamp=input('01JAN2008:12:34:56',datetime20.); actual=datepart(stamp)+timepart(stamp); run;

data _null_; if 0 then set t1368o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1368 rows=' rows;
else do; set t1368o; if not missing(actual) and abs(actual-(62828))<=1e-10*max(1,abs(62828)) then put 'ROUND3_PASS=T1368';
else put 'ERROR: ROUND3_FAIL=T1368 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1368:; quit;
