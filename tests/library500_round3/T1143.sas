/* T1143 cntlout_roundtrip, N=4; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:348 */

proc format library=work cntlout=t1143a; value t1143f 1='first' 5='last'; run;
proc sql; create table t1143o as select sum(input(start,best32.)) as actual from t1143a where upcase(fmtname)=upcase('t1143f'); quit;

data _null_; if 0 then set t1143o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1143 rows=' rows;
else do; set t1143o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1143';
else put 'ERROR: ROUND3_FAIL=T1143 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1143:; quit;
proc catalog catalog=work.formats; delete t1143f.format; quit;
