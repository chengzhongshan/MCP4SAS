/* R679 sort_nodupkey, N=10; source: SAS-Useful-Codes/Macros/HpmixArray.sas:628 */

data r679a; do k=10 to 1 by -1; value=k; output; value=999; output; end; run;
proc sort data=r679a out=r679b nodupkey equals; by k; run;
proc sql; create table r679o as select sum(value) as actual from r679b; quit;

data _null_; if 0 then set r679o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R679 rows=' rows;
else do; set r679o; if not missing(actual) and abs(actual-(55))<=1e-10*max(1,abs(55)) then put 'ROUND2_PASS=R679';
else put 'ERROR: ROUND2_FAIL=R679 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r679:; quit;
