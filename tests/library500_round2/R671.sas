/* R671 sort_nodupkey, N=2; source: SAS-Useful-Codes/Macros/HpmixArray.sas:628 */

data r671a; do k=2 to 1 by -1; value=k; output; value=999; output; end; run;
proc sort data=r671a out=r671b nodupkey equals; by k; run;
proc sql; create table r671o as select sum(value) as actual from r671b; quit;

data _null_; if 0 then set r671o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R671 rows=' rows;
else do; set r671o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND2_PASS=R671';
else put 'ERROR: ROUND2_FAIL=R671 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r671:; quit;
