/* R719 sum_statement_missing, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data r719a; do j=1 to 10; x=j; output; x=.; output; end; run;
data r719o; set r719a end=last; total+x; if last; actual=total; run;

data _null_; if 0 then set r719o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R719 rows=' rows;
else do; set r719o; if not missing(actual) and abs(actual-(55))<=1e-10*max(1,abs(55)) then put 'ROUND2_PASS=R719';
else put 'ERROR: ROUND2_FAIL=R719 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r719:; quit;
