/* R748 point_reverse, N=9; source: SAS-Useful-Codes/Macros/SAS-macros-master/boot.sas:1015 */

data r748a; do x=1 to 9; output; end; run;
data r748b; do ptr=9 to 1 by -1; set r748a point=ptr; weight=9-ptr+1; value=weight*x; output; end; stop; run;
proc sql; create table r748o as select sum(value) as actual from r748b; quit;

data _null_; if 0 then set r748o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R748 rows=' rows;
else do; set r748o; if not missing(actual) and abs(actual-(165))<=1e-10*max(1,abs(165)) then put 'ROUND2_PASS=R748';
else put 'ERROR: ROUND2_FAIL=R748 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r748:; quit;
