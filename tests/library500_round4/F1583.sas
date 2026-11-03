/* F1583 means_special_missing_counts, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1583a; do x=0 to 4; output; end; x=.A; output; x=.Z; output; run;
proc means data=f1583a noprint; var x; output out=f1583b n=valid nmiss=absent; run;
data f1583o; set f1583b; actual=10*valid+absent; run;

data _null_; if 0 then set f1583o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1583 rows=' rows;
else do; set f1583o; if not missing(actual) and abs(actual-(52))<=1e-9*max(1,abs(52)) then put 'ROUND4_PASS=F1583';
else put 'ERROR: ROUND4_FAIL=F1583 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1583:; quit;
