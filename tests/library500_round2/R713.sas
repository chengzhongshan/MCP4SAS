/* R713 sum_statement_missing, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data r713a; do j=1 to 4; x=j; output; x=.; output; end; run;
data r713o; set r713a end=last; total+x; if last; actual=total; run;

data _null_; if 0 then set r713o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R713 rows=' rows;
else do; set r713o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND2_PASS=R713';
else put 'ERROR: ROUND2_FAIL=R713 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r713:; quit;
