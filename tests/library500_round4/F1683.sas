/* F1683 corr_negative_affine, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1683a; do x=1 to 4+2; y=4-3*x; output; end; run;
proc corr data=f1683a outp=f1683b noprint; var x y; run;
data f1683o; set f1683b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1683o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1683 rows=' rows;
else do; set f1683o; if not missing(actual) and abs(actual-(-1))<=1e-9*max(1,abs(-1)) then put 'ROUND4_PASS=F1683';
else put 'ERROR: ROUND4_FAIL=F1683 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1683:; quit;
