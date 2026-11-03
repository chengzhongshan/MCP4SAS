/* R747 point_reverse, N=8; source: SAS-Useful-Codes/Macros/SAS-macros-master/boot.sas:1015 */

data r747a; do x=1 to 8; output; end; run;
data r747b; do ptr=8 to 1 by -1; set r747a point=ptr; weight=8-ptr+1; value=weight*x; output; end; stop; run;
proc sql; create table r747o as select sum(value) as actual from r747b; quit;

data _null_; if 0 then set r747o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R747 rows=' rows;
else do; set r747o; if not missing(actual) and abs(actual-(120))<=1e-10*max(1,abs(120)) then put 'ROUND2_PASS=R747';
else put 'ERROR: ROUND2_FAIL=R747 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r747:; quit;
