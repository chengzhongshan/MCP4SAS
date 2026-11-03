/* R686 sort_descending, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc sort in descending or ascending order.sas:11 */

data r686a; do x=1 to 7; output; end; run;
proc sort data=r686a out=r686b; by descending x; run;
data r686o; set r686b; if _n_=1; actual=x; run;

data _null_; if 0 then set r686o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R686 rows=' rows;
else do; set r686o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND2_PASS=R686';
else put 'ERROR: ROUND2_FAIL=R686 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r686:; quit;
