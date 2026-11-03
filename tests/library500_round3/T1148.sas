/* T1148 cntlout_roundtrip, N=9; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:348 */

proc format library=work cntlout=t1148a; value t1148f 1='first' 10='last'; run;
proc sql; create table t1148o as select sum(input(start,best32.)) as actual from t1148a where upcase(fmtname)=upcase('t1148f'); quit;

data _null_; if 0 then set t1148o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1148 rows=' rows;
else do; set t1148o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND3_PASS=T1148';
else put 'ERROR: ROUND3_FAIL=T1148 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1148:; quit;
proc catalog catalog=work.formats; delete t1148f.format; quit;
