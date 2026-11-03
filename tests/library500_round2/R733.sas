/* R733 dif_series, N=4; source: SAS-Useful-Codes/Macros/SAS-macros-master/boxplot.sas:529 */

data r733a; do x=1 to 4; value=x*x*x; output; end; run;
data r733b; set r733a; delta=dif(value); run;
proc sql; create table r733o as select sum(delta) as actual from r733b; quit;

data _null_; if 0 then set r733o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R733 rows=' rows;
else do; set r733o; if not missing(actual) and abs(actual-(63))<=1e-10*max(1,abs(63)) then put 'ROUND2_PASS=R733';
else put 'ERROR: ROUND2_FAIL=R733 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r733:; quit;
