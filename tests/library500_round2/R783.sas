/* R783 summary_weighted, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data r783a; do x=1 to 4; weight=x; output; end; run;
proc summary data=r783a; var x; weight weight; output out=r783b mean=average; run;
data r783o; set r783b; actual=average; run;

data _null_; if 0 then set r783o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R783 rows=' rows;
else do; set r783o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND2_PASS=R783';
else put 'ERROR: ROUND2_FAIL=R783 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r783:; quit;
