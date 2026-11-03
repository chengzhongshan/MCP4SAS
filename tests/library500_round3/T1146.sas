/* T1146 cntlout_roundtrip, N=7; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:348 */

proc format library=work cntlout=t1146a; value t1146f 1='first' 8='last'; run;
proc sql; create table t1146o as select sum(input(start,best32.)) as actual from t1146a where upcase(fmtname)=upcase('t1146f'); quit;

data _null_; if 0 then set t1146o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1146 rows=' rows;
else do; set t1146o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1146';
else put 'ERROR: ROUND3_FAIL=T1146 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1146:; quit;
proc catalog catalog=work.formats; delete t1146f.format; quit;
