/* R740 dif_series, N=11; source: SAS-Useful-Codes/Macros/SAS-macros-master/boxplot.sas:529 */

data r740a; do x=1 to 11; value=x*x*x; output; end; run;
data r740b; set r740a; delta=dif(value); run;
proc sql; create table r740o as select sum(delta) as actual from r740b; quit;

data _null_; if 0 then set r740o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R740 rows=' rows;
else do; set r740o; if not missing(actual) and abs(actual-(1330))<=1e-10*max(1,abs(1330)) then put 'ROUND2_PASS=R740';
else put 'ERROR: ROUND2_FAIL=R740 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r740:; quit;
