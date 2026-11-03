/* F1665 means_uncorrected_sum_squares, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1665a; do x=1 to 6; output; end; run;
proc means data=f1665a noprint; var x; output out=f1665o uss=actual; run;

data _null_; if 0 then set f1665o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1665 rows=' rows;
else do; set f1665o; if not missing(actual) and abs(actual-(91))<=1e-9*max(1,abs(91)) then put 'ROUND4_PASS=F1665';
else put 'ERROR: ROUND4_FAIL=F1665 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1665:; quit;
