/* T1150 cntlout_roundtrip, N=11; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:348 */

proc format library=work cntlout=t1150a; value t1150f 1='first' 12='last'; run;
proc sql; create table t1150o as select sum(input(start,best32.)) as actual from t1150a where upcase(fmtname)=upcase('t1150f'); quit;

data _null_; if 0 then set t1150o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1150 rows=' rows;
else do; set t1150o; if not missing(actual) and abs(actual-(13))<=1e-10*max(1,abs(13)) then put 'ROUND3_PASS=T1150';
else put 'ERROR: ROUND3_FAIL=T1150 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1150:; quit;
proc catalog catalog=work.formats; delete t1150f.format; quit;
