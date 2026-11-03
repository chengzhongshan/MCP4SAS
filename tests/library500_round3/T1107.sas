/* T1107 numeric_range_format, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/delete previous format before creating a new format.sas:1 */

proc format library=work; value t1107f low-0='nonpositive' 1-high='positive'; run;
data t1107a; do x=-8 to 8; matched=(put(x,t1107f.)='positive'); output; end; run;
proc sql; create table t1107o as select sum(matched) as actual from t1107a; quit;

data _null_; if 0 then set t1107o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1107 rows=' rows;
else do; set t1107o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1107';
else put 'ERROR: ROUND3_FAIL=T1107 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1107:; quit;
proc catalog catalog=work.formats; delete t1107f.format; quit;
