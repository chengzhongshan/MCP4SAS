/* R731 dif_series, N=2; source: SAS-Useful-Codes/Macros/SAS-macros-master/boxplot.sas:529 */

data r731a; do x=1 to 2; value=x*x*x; output; end; run;
data r731b; set r731a; delta=dif(value); run;
proc sql; create table r731o as select sum(delta) as actual from r731b; quit;

data _null_; if 0 then set r731o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R731 rows=' rows;
else do; set r731o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND2_PASS=R731';
else put 'ERROR: ROUND2_FAIL=R731 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r731:; quit;
