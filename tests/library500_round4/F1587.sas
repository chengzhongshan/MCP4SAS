/* F1587 means_special_missing_counts, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1587a; do x=0 to 8; output; end; x=.A; output; x=.Z; output; run;
proc means data=f1587a noprint; var x; output out=f1587b n=valid nmiss=absent; run;
data f1587o; set f1587b; actual=10*valid+absent; run;

data _null_; if 0 then set f1587o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1587 rows=' rows;
else do; set f1587o; if not missing(actual) and abs(actual-(92))<=1e-9*max(1,abs(92)) then put 'ROUND4_PASS=F1587';
else put 'ERROR: ROUND4_FAIL=F1587 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1587:; quit;
