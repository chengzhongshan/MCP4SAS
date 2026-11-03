/* R741 point_reverse, N=2; source: SAS-Useful-Codes/Macros/SAS-macros-master/boot.sas:1015 */

data r741a; do x=1 to 2; output; end; run;
data r741b; do ptr=2 to 1 by -1; set r741a point=ptr; weight=2-ptr+1; value=weight*x; output; end; stop; run;
proc sql; create table r741o as select sum(value) as actual from r741b; quit;

data _null_; if 0 then set r741o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R741 rows=' rows;
else do; set r741o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND2_PASS=R741';
else put 'ERROR: ROUND2_FAIL=R741 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r741:; quit;
