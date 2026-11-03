/* R744 point_reverse, N=5; source: SAS-Useful-Codes/Macros/SAS-macros-master/boot.sas:1015 */

data r744a; do x=1 to 5; output; end; run;
data r744b; do ptr=5 to 1 by -1; set r744a point=ptr; weight=5-ptr+1; value=weight*x; output; end; stop; run;
proc sql; create table r744o as select sum(value) as actual from r744b; quit;

data _null_; if 0 then set r744o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R744 rows=' rows;
else do; set r744o; if not missing(actual) and abs(actual-(35))<=1e-10*max(1,abs(35)) then put 'ROUND2_PASS=R744';
else put 'ERROR: ROUND2_FAIL=R744 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r744:; quit;
