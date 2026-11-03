/* T1464 prxparse_datastep_handle, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data t1464o; pattern=prxparse('/^[0-9]+$/'); actual=5+prxmatch(pattern,'5'); call prxfree(pattern); run;

data _null_; if 0 then set t1464o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1464 rows=' rows;
else do; set t1464o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1464';
else put 'ERROR: ROUND3_FAIL=T1464 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1464:; quit;
