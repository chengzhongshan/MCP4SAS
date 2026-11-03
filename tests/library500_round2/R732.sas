/* R732 dif_series, N=3; source: SAS-Useful-Codes/Macros/SAS-macros-master/boxplot.sas:529 */

data r732a; do x=1 to 3; value=x*x*x; output; end; run;
data r732b; set r732a; delta=dif(value); run;
proc sql; create table r732o as select sum(delta) as actual from r732b; quit;

data _null_; if 0 then set r732o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R732 rows=' rows;
else do; set r732o; if not missing(actual) and abs(actual-(26))<=1e-10*max(1,abs(26)) then put 'ROUND2_PASS=R732';
else put 'ERROR: ROUND2_FAIL=R732 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r732:; quit;
