/* R746 point_reverse, N=7; source: SAS-Useful-Codes/Macros/SAS-macros-master/boot.sas:1015 */

data r746a; do x=1 to 7; output; end; run;
data r746b; do ptr=7 to 1 by -1; set r746a point=ptr; weight=7-ptr+1; value=weight*x; output; end; stop; run;
proc sql; create table r746o as select sum(value) as actual from r746b; quit;

data _null_; if 0 then set r746o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R746 rows=' rows;
else do; set r746o; if not missing(actual) and abs(actual-(84))<=1e-10*max(1,abs(84)) then put 'ROUND2_PASS=R746';
else put 'ERROR: ROUND2_FAIL=R746 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r746:; quit;
