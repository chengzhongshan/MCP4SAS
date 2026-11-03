/* R712 sum_statement_missing, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data r712a; do j=1 to 3; x=j; output; x=.; output; end; run;
data r712o; set r712a end=last; total+x; if last; actual=total; run;

data _null_; if 0 then set r712o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R712 rows=' rows;
else do; set r712o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND2_PASS=R712';
else put 'ERROR: ROUND2_FAIL=R712 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r712:; quit;
