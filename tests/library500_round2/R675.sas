/* R675 sort_nodupkey, N=6; source: SAS-Useful-Codes/Macros/HpmixArray.sas:628 */

data r675a; do k=6 to 1 by -1; value=k; output; value=999; output; end; run;
proc sort data=r675a out=r675b nodupkey equals; by k; run;
proc sql; create table r675o as select sum(value) as actual from r675b; quit;

data _null_; if 0 then set r675o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R675 rows=' rows;
else do; set r675o; if not missing(actual) and abs(actual-(21))<=1e-10*max(1,abs(21)) then put 'ROUND2_PASS=R675';
else put 'ERROR: ROUND2_FAIL=R675 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r675:; quit;
