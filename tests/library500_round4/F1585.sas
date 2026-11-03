/* F1585 means_special_missing_counts, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1585a; do x=0 to 6; output; end; x=.A; output; x=.Z; output; run;
proc means data=f1585a noprint; var x; output out=f1585b n=valid nmiss=absent; run;
data f1585o; set f1585b; actual=10*valid+absent; run;

data _null_; if 0 then set f1585o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1585 rows=' rows;
else do; set f1585o; if not missing(actual) and abs(actual-(72))<=1e-9*max(1,abs(72)) then put 'ROUND4_PASS=F1585';
else put 'ERROR: ROUND4_FAIL=F1585 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1585:; quit;
