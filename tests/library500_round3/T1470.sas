/* T1470 prxparse_datastep_handle, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data t1470o; pattern=prxparse('/^[0-9]+$/'); actual=11+prxmatch(pattern,'11'); call prxfree(pattern); run;

data _null_; if 0 then set t1470o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1470 rows=' rows;
else do; set t1470o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND3_PASS=T1470';
else put 'ERROR: ROUND3_FAIL=T1470 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1470:; quit;
