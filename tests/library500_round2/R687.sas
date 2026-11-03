/* R687 sort_descending, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc sort in descending or ascending order.sas:11 */

data r687a; do x=1 to 8; output; end; run;
proc sort data=r687a out=r687b; by descending x; run;
data r687o; set r687b; if _n_=1; actual=x; run;

data _null_; if 0 then set r687o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R687 rows=' rows;
else do; set r687o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND2_PASS=R687';
else put 'ERROR: ROUND2_FAIL=R687 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r687:; quit;
