/* R682 sort_descending, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc sort in descending or ascending order.sas:11 */

data r682a; do x=1 to 3; output; end; run;
proc sort data=r682a out=r682b; by descending x; run;
data r682o; set r682b; if _n_=1; actual=x; run;

data _null_; if 0 then set r682o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R682 rows=' rows;
else do; set r682o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND2_PASS=R682';
else put 'ERROR: ROUND2_FAIL=R682 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r682:; quit;
