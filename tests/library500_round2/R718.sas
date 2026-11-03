/* R718 sum_statement_missing, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data r718a; do j=1 to 9; x=j; output; x=.; output; end; run;
data r718o; set r718a end=last; total+x; if last; actual=total; run;

data _null_; if 0 then set r718o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R718 rows=' rows;
else do; set r718o; if not missing(actual) and abs(actual-(45))<=1e-10*max(1,abs(45)) then put 'ROUND2_PASS=R718';
else put 'ERROR: ROUND2_FAIL=R718 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r718:; quit;
