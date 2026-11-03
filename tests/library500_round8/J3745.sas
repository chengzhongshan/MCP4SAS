/* J3745 by_notsorted_run_count, N=6; source: Step-by-Step Programming with Base SAS Software.txt:6195 */

data j3745a; do run=1 to 3; grp=mod(run,2); do j=1 to 6; output; end; end; run;
data j3745b; set j3745a; by grp notsorted; if first.grp; run;
proc sql; create table j3745o as select count(*) as actual from j3745b; quit;

data _null_; if 0 then set j3745o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3745 rows=' rows;
else do; set j3745o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3745';
else put 'ERROR: ROUND8_FAIL=J3745 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3745:; quit;
