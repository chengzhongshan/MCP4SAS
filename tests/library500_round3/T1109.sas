/* T1109 numeric_range_format, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/delete previous format before creating a new format.sas:1 */

proc format library=work; value t1109f low-0='nonpositive' 1-high='positive'; run;
data t1109a; do x=-10 to 10; matched=(put(x,t1109f.)='positive'); output; end; run;
proc sql; create table t1109o as select sum(matched) as actual from t1109a; quit;

data _null_; if 0 then set t1109o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1109 rows=' rows;
else do; set t1109o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1109';
else put 'ERROR: ROUND3_FAIL=T1109 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1109:; quit;
proc catalog catalog=work.formats; delete t1109f.format; quit;
