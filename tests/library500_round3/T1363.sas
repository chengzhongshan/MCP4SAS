/* T1363 datetime_components, N=4; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data t1363o; stamp=input('01JAN1988:12:34:56',datetime20.); actual=datepart(stamp)+timepart(stamp); run;

data _null_; if 0 then set t1363o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1363 rows=' rows;
else do; set t1363o; if not missing(actual) and abs(actual-(55523))<=1e-10*max(1,abs(55523)) then put 'ROUND3_PASS=T1363';
else put 'ERROR: ROUND3_FAIL=T1363 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1363:; quit;
