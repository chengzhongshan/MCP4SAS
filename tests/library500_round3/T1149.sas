/* T1149 cntlout_roundtrip, N=10; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:348 */

proc format library=work cntlout=t1149a; value t1149f 1='first' 11='last'; run;
proc sql; create table t1149o as select sum(input(start,best32.)) as actual from t1149a where upcase(fmtname)=upcase('t1149f'); quit;

data _null_; if 0 then set t1149o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1149 rows=' rows;
else do; set t1149o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND3_PASS=T1149';
else put 'ERROR: ROUND3_FAIL=T1149 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1149:; quit;
proc catalog catalog=work.formats; delete t1149f.format; quit;
