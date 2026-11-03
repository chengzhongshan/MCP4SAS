/* J3747 by_notsorted_run_count, N=8; source: Step-by-Step Programming with Base SAS Software.txt:6195 */

data j3747a; do run=1 to 3; grp=mod(run,2); do j=1 to 8; output; end; end; run;
data j3747b; set j3747a; by grp notsorted; if first.grp; run;
proc sql; create table j3747o as select count(*) as actual from j3747b; quit;

data _null_; if 0 then set j3747o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3747 rows=' rows;
else do; set j3747o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3747';
else put 'ERROR: ROUND8_FAIL=J3747 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3747:; quit;
