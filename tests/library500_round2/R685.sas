/* R685 sort_descending, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Proc sort in descending or ascending order.sas:11 */

data r685a; do x=1 to 6; output; end; run;
proc sort data=r685a out=r685b; by descending x; run;
data r685o; set r685b; if _n_=1; actual=x; run;

data _null_; if 0 then set r685o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R685 rows=' rows;
else do; set r685o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND2_PASS=R685';
else put 'ERROR: ROUND2_FAIL=R685 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r685:; quit;
