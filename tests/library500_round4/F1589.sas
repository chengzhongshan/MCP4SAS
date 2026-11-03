/* F1589 means_special_missing_counts, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1589a; do x=0 to 10; output; end; x=.A; output; x=.Z; output; run;
proc means data=f1589a noprint; var x; output out=f1589b n=valid nmiss=absent; run;
data f1589o; set f1589b; actual=10*valid+absent; run;

data _null_; if 0 then set f1589o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1589 rows=' rows;
else do; set f1589o; if not missing(actual) and abs(actual-(112))<=1e-9*max(1,abs(112)) then put 'ROUND4_PASS=F1589';
else put 'ERROR: ROUND4_FAIL=F1589 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1589:; quit;
