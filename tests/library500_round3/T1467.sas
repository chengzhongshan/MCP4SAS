/* T1467 prxparse_datastep_handle, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data t1467o; pattern=prxparse('/^[0-9]+$/'); actual=8+prxmatch(pattern,'8'); call prxfree(pattern); run;

data _null_; if 0 then set t1467o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1467 rows=' rows;
else do; set t1467o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1467';
else put 'ERROR: ROUND3_FAIL=T1467 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1467:; quit;
