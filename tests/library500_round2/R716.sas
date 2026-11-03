/* R716 sum_statement_missing, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data r716a; do j=1 to 7; x=j; output; x=.; output; end; run;
data r716o; set r716a end=last; total+x; if last; actual=total; run;

data _null_; if 0 then set r716o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R716 rows=' rows;
else do; set r716o; if not missing(actual) and abs(actual-(28))<=1e-10*max(1,abs(28)) then put 'ROUND2_PASS=R716';
else put 'ERROR: ROUND2_FAIL=R716 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r716:; quit;
