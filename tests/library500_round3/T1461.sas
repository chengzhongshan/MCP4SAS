/* T1461 prxparse_datastep_handle, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data t1461o; pattern=prxparse('/^[0-9]+$/'); actual=2+prxmatch(pattern,'2'); call prxfree(pattern); run;

data _null_; if 0 then set t1461o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1461 rows=' rows;
else do; set t1461o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND3_PASS=T1461';
else put 'ERROR: ROUND3_FAIL=T1461 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1461:; quit;
