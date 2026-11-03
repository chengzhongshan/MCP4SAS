/* T1106 numeric_range_format, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/delete previous format before creating a new format.sas:1 */

proc format library=work; value t1106f low-0='nonpositive' 1-high='positive'; run;
data t1106a; do x=-7 to 7; matched=(put(x,t1106f.)='positive'); output; end; run;
proc sql; create table t1106o as select sum(matched) as actual from t1106a; quit;

data _null_; if 0 then set t1106o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1106 rows=' rows;
else do; set t1106o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1106';
else put 'ERROR: ROUND3_FAIL=T1106 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1106:; quit;
proc catalog catalog=work.formats; delete t1106f.format; quit;
