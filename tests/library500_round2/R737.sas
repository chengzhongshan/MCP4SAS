/* R737 dif_series, N=8; source: SAS-Useful-Codes/Macros/SAS-macros-master/boxplot.sas:529 */

data r737a; do x=1 to 8; value=x*x*x; output; end; run;
data r737b; set r737a; delta=dif(value); run;
proc sql; create table r737o as select sum(delta) as actual from r737b; quit;

data _null_; if 0 then set r737o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R737 rows=' rows;
else do; set r737o; if not missing(actual) and abs(actual-(511))<=1e-10*max(1,abs(511)) then put 'ROUND2_PASS=R737';
else put 'ERROR: ROUND2_FAIL=R737 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r737:; quit;
