/* T1040 open_varnum, N=11; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:52 */

data t1040a; array x[11] v1-v11; do j=1 to 11; x[j]=j; end; drop j; run;
data t1040o; ds=open('t1040a','i'); actual=varnum(ds,'v11'); rc=close(ds); run;

data _null_; if 0 then set t1040o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1040 rows=' rows;
else do; set t1040o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND3_PASS=T1040';
else put 'ERROR: ROUND3_FAIL=T1040 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1040:; quit;
