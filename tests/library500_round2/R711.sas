/* R711 sum_statement_missing, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data r711a; do j=1 to 2; x=j; output; x=.; output; end; run;
data r711o; set r711a end=last; total+x; if last; actual=total; run;

data _null_; if 0 then set r711o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R711 rows=' rows;
else do; set r711o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND2_PASS=R711';
else put 'ERROR: ROUND2_FAIL=R711 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r711:; quit;
