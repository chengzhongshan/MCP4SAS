/* T1362 datetime_components, N=3; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data t1362o; stamp=input('01JAN1984:12:34:56',datetime20.); actual=datepart(stamp)+timepart(stamp); run;

data _null_; if 0 then set t1362o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1362 rows=' rows;
else do; set t1362o; if not missing(actual) and abs(actual-(54062))<=1e-10*max(1,abs(54062)) then put 'ROUND3_PASS=T1362';
else put 'ERROR: ROUND3_FAIL=T1362 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1362:; quit;
