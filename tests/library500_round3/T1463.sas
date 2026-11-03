/* T1463 prxparse_datastep_handle, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data t1463o; pattern=prxparse('/^[0-9]+$/'); actual=4+prxmatch(pattern,'4'); call prxfree(pattern); run;

data _null_; if 0 then set t1463o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1463 rows=' rows;
else do; set t1463o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1463';
else put 'ERROR: ROUND3_FAIL=T1463 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1463:; quit;
