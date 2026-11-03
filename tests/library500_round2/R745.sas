/* R745 point_reverse, N=6; source: SAS-Useful-Codes/Macros/SAS-macros-master/boot.sas:1015 */

data r745a; do x=1 to 6; output; end; run;
data r745b; do ptr=6 to 1 by -1; set r745a point=ptr; weight=6-ptr+1; value=weight*x; output; end; stop; run;
proc sql; create table r745o as select sum(value) as actual from r745b; quit;

data _null_; if 0 then set r745o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R745 rows=' rows;
else do; set r745o; if not missing(actual) and abs(actual-(56))<=1e-10*max(1,abs(56)) then put 'ROUND2_PASS=R745';
else put 'ERROR: ROUND2_FAIL=R745 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r745:; quit;
