/* F1677 corr_positive_affine, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1677a; do x=1 to 8+2; y=8+3*x; output; end; run;
proc corr data=f1677a outp=f1677b noprint; var x y; run;
data f1677o; set f1677b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1677o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1677 rows=' rows;
else do; set f1677o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1677';
else put 'ERROR: ROUND4_FAIL=F1677 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1677:; quit;
