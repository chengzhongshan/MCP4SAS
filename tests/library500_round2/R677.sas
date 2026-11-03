/* R677 sort_nodupkey, N=8; source: SAS-Useful-Codes/Macros/HpmixArray.sas:628 */

data r677a; do k=8 to 1 by -1; value=k; output; value=999; output; end; run;
proc sort data=r677a out=r677b nodupkey equals; by k; run;
proc sql; create table r677o as select sum(value) as actual from r677b; quit;

data _null_; if 0 then set r677o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R677 rows=' rows;
else do; set r677o; if not missing(actual) and abs(actual-(36))<=1e-10*max(1,abs(36)) then put 'ROUND2_PASS=R677';
else put 'ERROR: ROUND2_FAIL=R677 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r677:; quit;
