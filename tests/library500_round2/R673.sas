/* R673 sort_nodupkey, N=4; source: SAS-Useful-Codes/Macros/HpmixArray.sas:628 */

data r673a; do k=4 to 1 by -1; value=k; output; value=999; output; end; run;
proc sort data=r673a out=r673b nodupkey equals; by k; run;
proc sql; create table r673o as select sum(value) as actual from r673b; quit;

data _null_; if 0 then set r673o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R673 rows=' rows;
else do; set r673o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND2_PASS=R673';
else put 'ERROR: ROUND2_FAIL=R673 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r673:; quit;
