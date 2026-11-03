/* R672 sort_nodupkey, N=3; source: SAS-Useful-Codes/Macros/HpmixArray.sas:628 */

data r672a; do k=3 to 1 by -1; value=k; output; value=999; output; end; run;
proc sort data=r672a out=r672b nodupkey equals; by k; run;
proc sql; create table r672o as select sum(value) as actual from r672b; quit;

data _null_; if 0 then set r672o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R672 rows=' rows;
else do; set r672o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND2_PASS=R672';
else put 'ERROR: ROUND2_FAIL=R672 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r672:; quit;
