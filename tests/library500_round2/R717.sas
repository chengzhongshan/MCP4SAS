/* R717 sum_statement_missing, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data r717a; do j=1 to 8; x=j; output; x=.; output; end; run;
data r717o; set r717a end=last; total+x; if last; actual=total; run;

data _null_; if 0 then set r717o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R717 rows=' rows;
else do; set r717o; if not missing(actual) and abs(actual-(36))<=1e-10*max(1,abs(36)) then put 'ROUND2_PASS=R717';
else put 'ERROR: ROUND2_FAIL=R717 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r717:; quit;
