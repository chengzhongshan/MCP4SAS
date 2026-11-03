/* T1104 numeric_range_format, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/delete previous format before creating a new format.sas:1 */

proc format library=work; value t1104f low-0='nonpositive' 1-high='positive'; run;
data t1104a; do x=-5 to 5; matched=(put(x,t1104f.)='positive'); output; end; run;
proc sql; create table t1104o as select sum(matched) as actual from t1104a; quit;

data _null_; if 0 then set t1104o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1104 rows=' rows;
else do; set t1104o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1104';
else put 'ERROR: ROUND3_FAIL=T1104 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1104:; quit;
proc catalog catalog=work.formats; delete t1104f.format; quit;
