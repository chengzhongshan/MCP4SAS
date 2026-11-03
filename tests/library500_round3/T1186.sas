/* T1186 append_force_extra_column, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:19 */

data t1186a; do x=1 to 7; output; end; run;
data t1186b; do x=1 to 7; extra=x; output; end; run;
proc append base=t1186a data=t1186b force; run;
proc sql; create table t1186o as select sum(x) as actual from t1186a; quit;

data _null_; if 0 then set t1186o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1186 rows=' rows;
else do; set t1186o; if not missing(actual) and abs(actual-(56))<=1e-10*max(1,abs(56)) then put 'ROUND3_PASS=T1186';
else put 'ERROR: ROUND3_FAIL=T1186 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1186:; quit;
