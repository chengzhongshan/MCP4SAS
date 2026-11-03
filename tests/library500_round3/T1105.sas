/* T1105 numeric_range_format, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/delete previous format before creating a new format.sas:1 */

proc format library=work; value t1105f low-0='nonpositive' 1-high='positive'; run;
data t1105a; do x=-6 to 6; matched=(put(x,t1105f.)='positive'); output; end; run;
proc sql; create table t1105o as select sum(matched) as actual from t1105a; quit;

data _null_; if 0 then set t1105o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1105 rows=' rows;
else do; set t1105o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1105';
else put 'ERROR: ROUND3_FAIL=T1105 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1105:; quit;
proc catalog catalog=work.formats; delete t1105f.format; quit;
