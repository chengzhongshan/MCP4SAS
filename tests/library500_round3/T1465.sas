/* T1465 prxparse_datastep_handle, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data t1465o; pattern=prxparse('/^[0-9]+$/'); actual=6+prxmatch(pattern,'6'); call prxfree(pattern); run;

data _null_; if 0 then set t1465o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1465 rows=' rows;
else do; set t1465o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1465';
else put 'ERROR: ROUND3_FAIL=T1465 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1465:; quit;
