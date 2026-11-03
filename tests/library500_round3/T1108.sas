/* T1108 numeric_range_format, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/delete previous format before creating a new format.sas:1 */

proc format library=work; value t1108f low-0='nonpositive' 1-high='positive'; run;
data t1108a; do x=-9 to 9; matched=(put(x,t1108f.)='positive'); output; end; run;
proc sql; create table t1108o as select sum(matched) as actual from t1108a; quit;

data _null_; if 0 then set t1108o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1108 rows=' rows;
else do; set t1108o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1108';
else put 'ERROR: ROUND3_FAIL=T1108 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1108:; quit;
proc catalog catalog=work.formats; delete t1108f.format; quit;
