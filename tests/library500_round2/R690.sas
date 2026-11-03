/* R690 sort_descending, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc sort in descending or ascending order.sas:11 */

data r690a; do x=1 to 11; output; end; run;
proc sort data=r690a out=r690b; by descending x; run;
data r690o; set r690b; if _n_=1; actual=x; run;

data _null_; if 0 then set r690o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R690 rows=' rows;
else do; set r690o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND2_PASS=R690';
else put 'ERROR: ROUND2_FAIL=R690 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r690:; quit;
