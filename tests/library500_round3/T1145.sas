/* T1145 cntlout_roundtrip, N=6; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:348 */

proc format library=work cntlout=t1145a; value t1145f 1='first' 7='last'; run;
proc sql; create table t1145o as select sum(input(start,best32.)) as actual from t1145a where upcase(fmtname)=upcase('t1145f'); quit;

data _null_; if 0 then set t1145o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1145 rows=' rows;
else do; set t1145o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1145';
else put 'ERROR: ROUND3_FAIL=T1145 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1145:; quit;
proc catalog catalog=work.formats; delete t1145f.format; quit;
