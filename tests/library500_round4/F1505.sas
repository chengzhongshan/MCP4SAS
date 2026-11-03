/* F1505 means_sample_variance, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1505a; do x=1 to 6; output; end; run;
proc means data=f1505a noprint; var x; output out=f1505o var=actual; run;

data _null_; if 0 then set f1505o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1505 rows=' rows;
else do; set f1505o; if not missing(actual) and abs(actual-(3.5))<=1e-9*max(1,abs(3.5)) then put 'ROUND4_PASS=F1505';
else put 'ERROR: ROUND4_FAIL=F1505 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1505:; quit;
