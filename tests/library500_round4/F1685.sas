/* F1685 corr_negative_affine, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1685a; do x=1 to 6+2; y=6-3*x; output; end; run;
proc corr data=f1685a outp=f1685b noprint; var x y; run;
data f1685o; set f1685b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1685o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1685 rows=' rows;
else do; set f1685o; if not missing(actual) and abs(actual-(-1))<=1e-9*max(1,abs(-1)) then put 'ROUND4_PASS=F1685';
else put 'ERROR: ROUND4_FAIL=F1685 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1685:; quit;
