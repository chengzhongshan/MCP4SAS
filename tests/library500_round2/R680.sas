/* R680 sort_nodupkey, N=11; source: SAS-Useful-Codes/Macros/HpmixArray.sas:628 */

data r680a; do k=11 to 1 by -1; value=k; output; value=999; output; end; run;
proc sort data=r680a out=r680b nodupkey equals; by k; run;
proc sql; create table r680o as select sum(value) as actual from r680b; quit;

data _null_; if 0 then set r680o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R680 rows=' rows;
else do; set r680o; if not missing(actual) and abs(actual-(66))<=1e-10*max(1,abs(66)) then put 'ROUND2_PASS=R680';
else put 'ERROR: ROUND2_FAIL=R680 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r680:; quit;
