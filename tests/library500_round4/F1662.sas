/* F1662 means_uncorrected_sum_squares, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1662a; do x=1 to 3; output; end; run;
proc means data=f1662a noprint; var x; output out=f1662o uss=actual; run;

data _null_; if 0 then set f1662o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1662 rows=' rows;
else do; set f1662o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND4_PASS=F1662';
else put 'ERROR: ROUND4_FAIL=F1662 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1662:; quit;
