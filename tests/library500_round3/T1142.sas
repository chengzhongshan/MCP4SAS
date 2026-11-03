/* T1142 cntlout_roundtrip, N=3; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:348 */

proc format library=work cntlout=t1142a; value t1142f 1='first' 4='last'; run;
proc sql; create table t1142o as select sum(input(start,best32.)) as actual from t1142a where upcase(fmtname)=upcase('t1142f'); quit;

data _null_; if 0 then set t1142o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1142 rows=' rows;
else do; set t1142o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1142';
else put 'ERROR: ROUND3_FAIL=T1142 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1142:; quit;
proc catalog catalog=work.formats; delete t1142f.format; quit;
