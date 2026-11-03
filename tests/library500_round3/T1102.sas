/* T1102 numeric_range_format, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/delete previous format before creating a new format.sas:1 */

proc format library=work; value t1102f low-0='nonpositive' 1-high='positive'; run;
data t1102a; do x=-3 to 3; matched=(put(x,t1102f.)='positive'); output; end; run;
proc sql; create table t1102o as select sum(matched) as actual from t1102a; quit;

data _null_; if 0 then set t1102o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1102 rows=' rows;
else do; set t1102o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND3_PASS=T1102';
else put 'ERROR: ROUND3_FAIL=T1102 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1102:; quit;
proc catalog catalog=work.formats; delete t1102f.format; quit;
