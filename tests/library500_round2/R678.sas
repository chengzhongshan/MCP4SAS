/* R678 sort_nodupkey, N=9; source: SAS-Useful-Codes/Macros/HpmixArray.sas:628 */

data r678a; do k=9 to 1 by -1; value=k; output; value=999; output; end; run;
proc sort data=r678a out=r678b nodupkey equals; by k; run;
proc sql; create table r678o as select sum(value) as actual from r678b; quit;

data _null_; if 0 then set r678o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R678 rows=' rows;
else do; set r678o; if not missing(actual) and abs(actual-(45))<=1e-10*max(1,abs(45)) then put 'ROUND2_PASS=R678';
else put 'ERROR: ROUND2_FAIL=R678 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r678:; quit;
