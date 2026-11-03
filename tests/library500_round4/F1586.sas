/* F1586 means_special_missing_counts, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1586a; do x=0 to 7; output; end; x=.A; output; x=.Z; output; run;
proc means data=f1586a noprint; var x; output out=f1586b n=valid nmiss=absent; run;
data f1586o; set f1586b; actual=10*valid+absent; run;

data _null_; if 0 then set f1586o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1586 rows=' rows;
else do; set f1586o; if not missing(actual) and abs(actual-(82))<=1e-9*max(1,abs(82)) then put 'ROUND4_PASS=F1586';
else put 'ERROR: ROUND4_FAIL=F1586 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1586:; quit;
