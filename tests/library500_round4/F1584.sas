/* F1584 means_special_missing_counts, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1584a; do x=0 to 5; output; end; x=.A; output; x=.Z; output; run;
proc means data=f1584a noprint; var x; output out=f1584b n=valid nmiss=absent; run;
data f1584o; set f1584b; actual=10*valid+absent; run;

data _null_; if 0 then set f1584o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1584 rows=' rows;
else do; set f1584o; if not missing(actual) and abs(actual-(62))<=1e-9*max(1,abs(62)) then put 'ROUND4_PASS=F1584';
else put 'ERROR: ROUND4_FAIL=F1584 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1584:; quit;
