/* T1462 prxparse_datastep_handle, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data t1462o; pattern=prxparse('/^[0-9]+$/'); actual=3+prxmatch(pattern,'3'); call prxfree(pattern); run;

data _null_; if 0 then set t1462o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1462 rows=' rows;
else do; set t1462o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND3_PASS=T1462';
else put 'ERROR: ROUND3_FAIL=T1462 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1462:; quit;
