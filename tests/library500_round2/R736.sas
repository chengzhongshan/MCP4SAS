/* R736 dif_series, N=7; source: SAS-Useful-Codes/Macros/SAS-macros-master/boxplot.sas:529 */

data r736a; do x=1 to 7; value=x*x*x; output; end; run;
data r736b; set r736a; delta=dif(value); run;
proc sql; create table r736o as select sum(delta) as actual from r736b; quit;

data _null_; if 0 then set r736o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R736 rows=' rows;
else do; set r736o; if not missing(actual) and abs(actual-(342))<=1e-10*max(1,abs(342)) then put 'ROUND2_PASS=R736';
else put 'ERROR: ROUND2_FAIL=R736 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r736:; quit;
