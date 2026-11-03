/* T1101 numeric_range_format, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/delete previous format before creating a new format.sas:1 */

proc format library=work; value t1101f low-0='nonpositive' 1-high='positive'; run;
data t1101a; do x=-2 to 2; matched=(put(x,t1101f.)='positive'); output; end; run;
proc sql; create table t1101o as select sum(matched) as actual from t1101a; quit;

data _null_; if 0 then set t1101o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1101 rows=' rows;
else do; set t1101o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1101';
else put 'ERROR: ROUND3_FAIL=T1101 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1101:; quit;
proc catalog catalog=work.formats; delete t1101f.format; quit;
