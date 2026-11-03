/* R674 sort_nodupkey, N=5; source: SAS-Useful-Codes/Macros/HpmixArray.sas:628 */

data r674a; do k=5 to 1 by -1; value=k; output; value=999; output; end; run;
proc sort data=r674a out=r674b nodupkey equals; by k; run;
proc sql; create table r674o as select sum(value) as actual from r674b; quit;

data _null_; if 0 then set r674o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R674 rows=' rows;
else do; set r674o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND2_PASS=R674';
else put 'ERROR: ROUND2_FAIL=R674 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r674:; quit;
