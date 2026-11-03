/* T1469 prxparse_datastep_handle, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data t1469o; pattern=prxparse('/^[0-9]+$/'); actual=10+prxmatch(pattern,'10'); call prxfree(pattern); run;

data _null_; if 0 then set t1469o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1469 rows=' rows;
else do; set t1469o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND3_PASS=T1469';
else put 'ERROR: ROUND3_FAIL=T1469 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1469:; quit;
