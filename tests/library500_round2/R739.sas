/* R739 dif_series, N=10; source: SAS-Useful-Codes/Macros/SAS-macros-master/boxplot.sas:529 */

data r739a; do x=1 to 10; value=x*x*x; output; end; run;
data r739b; set r739a; delta=dif(value); run;
proc sql; create table r739o as select sum(delta) as actual from r739b; quit;

data _null_; if 0 then set r739o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R739 rows=' rows;
else do; set r739o; if not missing(actual) and abs(actual-(999))<=1e-10*max(1,abs(999)) then put 'ROUND2_PASS=R739';
else put 'ERROR: ROUND2_FAIL=R739 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r739:; quit;
