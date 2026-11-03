/* F1674 corr_positive_affine, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1674a; do x=1 to 5+2; y=5+3*x; output; end; run;
proc corr data=f1674a outp=f1674b noprint; var x y; run;
data f1674o; set f1674b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1674o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1674 rows=' rows;
else do; set f1674o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1674';
else put 'ERROR: ROUND4_FAIL=F1674 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1674:; quit;
