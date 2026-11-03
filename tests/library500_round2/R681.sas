/* R681 sort_descending, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc sort in descending or ascending order.sas:11 */

data r681a; do x=1 to 2; output; end; run;
proc sort data=r681a out=r681b; by descending x; run;
data r681o; set r681b; if _n_=1; actual=x; run;

data _null_; if 0 then set r681o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R681 rows=' rows;
else do; set r681o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND2_PASS=R681';
else put 'ERROR: ROUND2_FAIL=R681 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r681:; quit;
