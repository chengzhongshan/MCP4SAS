/* R734 dif_series, N=5; source: SAS-Useful-Codes/Macros/SAS-macros-master/boxplot.sas:529 */

data r734a; do x=1 to 5; value=x*x*x; output; end; run;
data r734b; set r734a; delta=dif(value); run;
proc sql; create table r734o as select sum(delta) as actual from r734b; quit;

data _null_; if 0 then set r734o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R734 rows=' rows;
else do; set r734o; if not missing(actual) and abs(actual-(124))<=1e-10*max(1,abs(124)) then put 'ROUND2_PASS=R734';
else put 'ERROR: ROUND2_FAIL=R734 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r734:; quit;
