/* T1365 datetime_components, N=6; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data t1365o; stamp=input('01JAN1996:12:34:56',datetime20.); actual=datepart(stamp)+timepart(stamp); run;

data _null_; if 0 then set t1365o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1365 rows=' rows;
else do; set t1365o; if not missing(actual) and abs(actual-(58445))<=1e-10*max(1,abs(58445)) then put 'ROUND3_PASS=T1365';
else put 'ERROR: ROUND3_FAIL=T1365 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1365:; quit;
