/* R688 sort_descending, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc sort in descending or ascending order.sas:11 */

data r688a; do x=1 to 9; output; end; run;
proc sort data=r688a out=r688b; by descending x; run;
data r688o; set r688b; if _n_=1; actual=x; run;

data _null_; if 0 then set r688o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R688 rows=' rows;
else do; set r688o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND2_PASS=R688';
else put 'ERROR: ROUND2_FAIL=R688 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r688:; quit;
