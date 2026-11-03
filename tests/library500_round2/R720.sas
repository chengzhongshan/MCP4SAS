/* R720 sum_statement_missing, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data r720a; do j=1 to 11; x=j; output; x=.; output; end; run;
data r720o; set r720a end=last; total+x; if last; actual=total; run;

data _null_; if 0 then set r720o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R720 rows=' rows;
else do; set r720o; if not missing(actual) and abs(actual-(66))<=1e-10*max(1,abs(66)) then put 'ROUND2_PASS=R720';
else put 'ERROR: ROUND2_FAIL=R720 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r720:; quit;
