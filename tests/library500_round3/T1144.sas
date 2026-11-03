/* T1144 cntlout_roundtrip, N=5; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:348 */

proc format library=work cntlout=t1144a; value t1144f 1='first' 6='last'; run;
proc sql; create table t1144o as select sum(input(start,best32.)) as actual from t1144a where upcase(fmtname)=upcase('t1144f'); quit;

data _null_; if 0 then set t1144o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1144 rows=' rows;
else do; set t1144o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1144';
else put 'ERROR: ROUND3_FAIL=T1144 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1144:; quit;
proc catalog catalog=work.formats; delete t1144f.format; quit;
