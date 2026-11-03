/* R715 sum_statement_missing, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data r715a; do j=1 to 6; x=j; output; x=.; output; end; run;
data r715o; set r715a end=last; total+x; if last; actual=total; run;

data _null_; if 0 then set r715o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R715 rows=' rows;
else do; set r715o; if not missing(actual) and abs(actual-(21))<=1e-10*max(1,abs(21)) then put 'ROUND2_PASS=R715';
else put 'ERROR: ROUND2_FAIL=R715 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r715:; quit;
