/* T1466 prxparse_datastep_handle, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data t1466o; pattern=prxparse('/^[0-9]+$/'); actual=7+prxmatch(pattern,'7'); call prxfree(pattern); run;

data _null_; if 0 then set t1466o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1466 rows=' rows;
else do; set t1466o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1466';
else put 'ERROR: ROUND3_FAIL=T1466 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1466:; quit;
