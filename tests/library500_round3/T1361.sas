/* T1361 datetime_components, N=2; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data t1361o; stamp=input('01JAN1980:12:34:56',datetime20.); actual=datepart(stamp)+timepart(stamp); run;

data _null_; if 0 then set t1361o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1361 rows=' rows;
else do; set t1361o; if not missing(actual) and abs(actual-(52601))<=1e-10*max(1,abs(52601)) then put 'ROUND3_PASS=T1361';
else put 'ERROR: ROUND3_FAIL=T1361 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1361:; quit;
