/* T1110 numeric_range_format, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/delete previous format before creating a new format.sas:1 */

proc format library=work; value t1110f low-0='nonpositive' 1-high='positive'; run;
data t1110a; do x=-11 to 11; matched=(put(x,t1110f.)='positive'); output; end; run;
proc sql; create table t1110o as select sum(matched) as actual from t1110a; quit;

data _null_; if 0 then set t1110o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1110 rows=' rows;
else do; set t1110o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND3_PASS=T1110';
else put 'ERROR: ROUND3_FAIL=T1110 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1110:; quit;
proc catalog catalog=work.formats; delete t1110f.format; quit;
