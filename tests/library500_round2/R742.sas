/* R742 point_reverse, N=3; source: SAS-Useful-Codes/Macros/SAS-macros-master/boot.sas:1015 */

data r742a; do x=1 to 3; output; end; run;
data r742b; do ptr=3 to 1 by -1; set r742a point=ptr; weight=3-ptr+1; value=weight*x; output; end; stop; run;
proc sql; create table r742o as select sum(value) as actual from r742b; quit;

data _null_; if 0 then set r742o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R742 rows=' rows;
else do; set r742o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND2_PASS=R742';
else put 'ERROR: ROUND2_FAIL=R742 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r742:; quit;
