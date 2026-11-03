/* R750 point_reverse, N=11; source: SAS-Useful-Codes/Macros/SAS-macros-master/boot.sas:1015 */

data r750a; do x=1 to 11; output; end; run;
data r750b; do ptr=11 to 1 by -1; set r750a point=ptr; weight=11-ptr+1; value=weight*x; output; end; stop; run;
proc sql; create table r750o as select sum(value) as actual from r750b; quit;

data _null_; if 0 then set r750o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R750 rows=' rows;
else do; set r750o; if not missing(actual) and abs(actual-(286))<=1e-10*max(1,abs(286)) then put 'ROUND2_PASS=R750';
else put 'ERROR: ROUND2_FAIL=R750 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r750:; quit;
