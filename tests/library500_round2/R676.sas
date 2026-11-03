/* R676 sort_nodupkey, N=7; source: SAS-Useful-Codes/Macros/HpmixArray.sas:628 */

data r676a; do k=7 to 1 by -1; value=k; output; value=999; output; end; run;
proc sort data=r676a out=r676b nodupkey equals; by k; run;
proc sql; create table r676o as select sum(value) as actual from r676b; quit;

data _null_; if 0 then set r676o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R676 rows=' rows;
else do; set r676o; if not missing(actual) and abs(actual-(28))<=1e-10*max(1,abs(28)) then put 'ROUND2_PASS=R676';
else put 'ERROR: ROUND2_FAIL=R676 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r676:; quit;
