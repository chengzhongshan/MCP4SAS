/* R684 sort_descending, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc sort in descending or ascending order.sas:11 */

data r684a; do x=1 to 5; output; end; run;
proc sort data=r684a out=r684b; by descending x; run;
data r684o; set r684b; if _n_=1; actual=x; run;

data _null_; if 0 then set r684o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R684 rows=' rows;
else do; set r684o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND2_PASS=R684';
else put 'ERROR: ROUND2_FAIL=R684 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r684:; quit;
