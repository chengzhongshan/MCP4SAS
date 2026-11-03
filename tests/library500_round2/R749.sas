/* R749 point_reverse, N=10; source: SAS-Useful-Codes/Macros/SAS-macros-master/boot.sas:1015 */

data r749a; do x=1 to 10; output; end; run;
data r749b; do ptr=10 to 1 by -1; set r749a point=ptr; weight=10-ptr+1; value=weight*x; output; end; stop; run;
proc sql; create table r749o as select sum(value) as actual from r749b; quit;

data _null_; if 0 then set r749o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R749 rows=' rows;
else do; set r749o; if not missing(actual) and abs(actual-(220))<=1e-10*max(1,abs(220)) then put 'ROUND2_PASS=R749';
else put 'ERROR: ROUND2_FAIL=R749 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r749:; quit;
