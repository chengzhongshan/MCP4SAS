/* T1147 cntlout_roundtrip, N=8; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:348 */

proc format library=work cntlout=t1147a; value t1147f 1='first' 9='last'; run;
proc sql; create table t1147o as select sum(input(start,best32.)) as actual from t1147a where upcase(fmtname)=upcase('t1147f'); quit;

data _null_; if 0 then set t1147o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1147 rows=' rows;
else do; set t1147o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1147';
else put 'ERROR: ROUND3_FAIL=T1147 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1147:; quit;
proc catalog catalog=work.formats; delete t1147f.format; quit;
