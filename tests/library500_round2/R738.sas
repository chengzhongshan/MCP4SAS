/* R738 dif_series, N=9; source: SAS-Useful-Codes/Macros/SAS-macros-master/boxplot.sas:529 */

data r738a; do x=1 to 9; value=x*x*x; output; end; run;
data r738b; set r738a; delta=dif(value); run;
proc sql; create table r738o as select sum(delta) as actual from r738b; quit;

data _null_; if 0 then set r738o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R738 rows=' rows;
else do; set r738o; if not missing(actual) and abs(actual-(728))<=1e-10*max(1,abs(728)) then put 'ROUND2_PASS=R738';
else put 'ERROR: ROUND2_FAIL=R738 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r738:; quit;
