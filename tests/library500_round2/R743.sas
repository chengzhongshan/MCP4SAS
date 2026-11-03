/* R743 point_reverse, N=4; source: SAS-Useful-Codes/Macros/SAS-macros-master/boot.sas:1015 */

data r743a; do x=1 to 4; output; end; run;
data r743b; do ptr=4 to 1 by -1; set r743a point=ptr; weight=4-ptr+1; value=weight*x; output; end; stop; run;
proc sql; create table r743o as select sum(value) as actual from r743b; quit;

data _null_; if 0 then set r743o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R743 rows=' rows;
else do; set r743o; if not missing(actual) and abs(actual-(20))<=1e-10*max(1,abs(20)) then put 'ROUND2_PASS=R743';
else put 'ERROR: ROUND2_FAIL=R743 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r743:; quit;
