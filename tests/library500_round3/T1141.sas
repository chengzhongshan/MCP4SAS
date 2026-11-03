/* T1141 cntlout_roundtrip, N=2; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:348 */

proc format library=work cntlout=t1141a; value t1141f 1='first' 3='last'; run;
proc sql; create table t1141o as select sum(input(start,best32.)) as actual from t1141a where upcase(fmtname)=upcase('t1141f'); quit;

data _null_; if 0 then set t1141o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1141 rows=' rows;
else do; set t1141o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND3_PASS=T1141';
else put 'ERROR: ROUND3_FAIL=T1141 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1141:; quit;
proc catalog catalog=work.formats; delete t1141f.format; quit;
