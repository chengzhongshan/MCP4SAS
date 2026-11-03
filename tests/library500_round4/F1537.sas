/* F1537 means_coefficient_variation, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1537a; do x=1 to 8; output; end; run;
proc means data=f1537a noprint; var x; output out=f1537o cv=actual; run;

data _null_; if 0 then set f1537o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1537 rows=' rows;
else do; set f1537o; if not missing(actual) and abs(actual-(54.4331053951817))<=1e-9*max(1,abs(54.4331053951817)) then put 'ROUND4_PASS=F1537';
else put 'ERROR: ROUND4_FAIL=F1537 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1537:; quit;
