/* R735 dif_series, N=6; source: SAS-Useful-Codes/Macros/SAS-macros-master/boxplot.sas:529 */

data r735a; do x=1 to 6; value=x*x*x; output; end; run;
data r735b; set r735a; delta=dif(value); run;
proc sql; create table r735o as select sum(delta) as actual from r735b; quit;

data _null_; if 0 then set r735o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R735 rows=' rows;
else do; set r735o; if not missing(actual) and abs(actual-(215))<=1e-10*max(1,abs(215)) then put 'ROUND2_PASS=R735';
else put 'ERROR: ROUND2_FAIL=R735 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r735:; quit;
