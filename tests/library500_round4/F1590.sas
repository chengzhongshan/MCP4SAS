/* F1590 means_special_missing_counts, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1590a; do x=0 to 11; output; end; x=.A; output; x=.Z; output; run;
proc means data=f1590a noprint; var x; output out=f1590b n=valid nmiss=absent; run;
data f1590o; set f1590b; actual=10*valid+absent; run;

data _null_; if 0 then set f1590o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1590 rows=' rows;
else do; set f1590o; if not missing(actual) and abs(actual-(122))<=1e-9*max(1,abs(122)) then put 'ROUND4_PASS=F1590';
else put 'ERROR: ROUND4_FAIL=F1590 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1590:; quit;
