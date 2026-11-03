/* T1103 numeric_range_format, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/delete previous format before creating a new format.sas:1 */

proc format library=work; value t1103f low-0='nonpositive' 1-high='positive'; run;
data t1103a; do x=-4 to 4; matched=(put(x,t1103f.)='positive'); output; end; run;
proc sql; create table t1103o as select sum(matched) as actual from t1103a; quit;

data _null_; if 0 then set t1103o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1103 rows=' rows;
else do; set t1103o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND3_PASS=T1103';
else put 'ERROR: ROUND3_FAIL=T1103 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1103:; quit;
proc catalog catalog=work.formats; delete t1103f.format; quit;
