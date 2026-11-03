/* R714 sum_statement_missing, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data r714a; do j=1 to 5; x=j; output; x=.; output; end; run;
data r714o; set r714a end=last; total+x; if last; actual=total; run;

data _null_; if 0 then set r714o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R714 rows=' rows;
else do; set r714o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND2_PASS=R714';
else put 'ERROR: ROUND2_FAIL=R714 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r714:; quit;
