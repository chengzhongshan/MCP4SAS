/* R706 retain_product, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data r706a; do x=1 to 7; output; end; run;
data r706o; set r706a end=last; retain product 1; product=product*x; if last; actual=product; run;

data _null_; if 0 then set r706o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R706 rows=' rows;
else do; set r706o; if not missing(actual) and abs(actual-(5040))<=1e-10*max(1,abs(5040)) then put 'ROUND2_PASS=R706';
else put 'ERROR: ROUND2_FAIL=R706 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r706:; quit;
