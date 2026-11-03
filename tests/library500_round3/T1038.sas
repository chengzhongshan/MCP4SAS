/* T1038 open_varnum, N=9; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:52 */

data t1038a; array x[9] v1-v9; do j=1 to 9; x[j]=j; end; drop j; run;
data t1038o; ds=open('t1038a','i'); actual=varnum(ds,'v9'); rc=close(ds); run;

data _null_; if 0 then set t1038o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1038 rows=' rows;
else do; set t1038o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1038';
else put 'ERROR: ROUND3_FAIL=T1038 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1038:; quit;
