/* F1681 corr_negative_affine, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1681a; do x=1 to 2+2; y=2-3*x; output; end; run;
proc corr data=f1681a outp=f1681b noprint; var x y; run;
data f1681o; set f1681b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1681o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1681 rows=' rows;
else do; set f1681o; if not missing(actual) and abs(actual-(-1))<=1e-9*max(1,abs(-1)) then put 'ROUND4_PASS=F1681';
else put 'ERROR: ROUND4_FAIL=F1681 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1681:; quit;
