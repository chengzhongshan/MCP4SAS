/* R683 sort_descending, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc sort in descending or ascending order.sas:11 */

data r683a; do x=1 to 4; output; end; run;
proc sort data=r683a out=r683b; by descending x; run;
data r683o; set r683b; if _n_=1; actual=x; run;

data _null_; if 0 then set r683o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R683 rows=' rows;
else do; set r683o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND2_PASS=R683';
else put 'ERROR: ROUND2_FAIL=R683 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r683:; quit;
