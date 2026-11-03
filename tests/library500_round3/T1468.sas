/* T1468 prxparse_datastep_handle, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data t1468o; pattern=prxparse('/^[0-9]+$/'); actual=9+prxmatch(pattern,'9'); call prxfree(pattern); run;

data _null_; if 0 then set t1468o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1468 rows=' rows;
else do; set t1468o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1468';
else put 'ERROR: ROUND3_FAIL=T1468 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1468:; quit;
