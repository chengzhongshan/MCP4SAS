/* J3743 by_notsorted_run_count, N=4; source: Step-by-Step Programming with Base SAS Software.txt:6195 */

data j3743a; do run=1 to 3; grp=mod(run,2); do j=1 to 4; output; end; end; run;
data j3743b; set j3743a; by grp notsorted; if first.grp; run;
proc sql; create table j3743o as select count(*) as actual from j3743b; quit;

data _null_; if 0 then set j3743o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3743 rows=' rows;
else do; set j3743o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3743';
else put 'ERROR: ROUND8_FAIL=J3743 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3743:; quit;
