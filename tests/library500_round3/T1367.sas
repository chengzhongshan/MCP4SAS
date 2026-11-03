/* T1367 datetime_components, N=8; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data t1367o; stamp=input('01JAN2004:12:34:56',datetime20.); actual=datepart(stamp)+timepart(stamp); run;

data _null_; if 0 then set t1367o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1367 rows=' rows;
else do; set t1367o; if not missing(actual) and abs(actual-(61367))<=1e-10*max(1,abs(61367)) then put 'ROUND3_PASS=T1367';
else put 'ERROR: ROUND3_FAIL=T1367 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1367:; quit;
