/* F1506 means_sample_variance, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1506a; do x=1 to 7; output; end; run;
proc means data=f1506a noprint; var x; output out=f1506o var=actual; run;

data _null_; if 0 then set f1506o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1506 rows=' rows;
else do; set f1506o; if not missing(actual) and abs(actual-(4.66666666666667))<=1e-9*max(1,abs(4.66666666666667)) then put 'ROUND4_PASS=F1506';
else put 'ERROR: ROUND4_FAIL=F1506 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1506:; quit;
