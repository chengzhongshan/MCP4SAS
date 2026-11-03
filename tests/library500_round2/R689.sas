/* R689 sort_descending, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc sort in descending or ascending order.sas:11 */

data r689a; do x=1 to 10; output; end; run;
proc sort data=r689a out=r689b; by descending x; run;
data r689o; set r689b; if _n_=1; actual=x; run;

data _null_; if 0 then set r689o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R689 rows=' rows;
else do; set r689o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND2_PASS=R689';
else put 'ERROR: ROUND2_FAIL=R689 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r689:; quit;
