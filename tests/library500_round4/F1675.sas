/* F1675 corr_positive_affine, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1675a; do x=1 to 6+2; y=6+3*x; output; end; run;
proc corr data=f1675a outp=f1675b noprint; var x y; run;
data f1675o; set f1675b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1675o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1675 rows=' rows;
else do; set f1675o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1675';
else put 'ERROR: ROUND4_FAIL=F1675 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1675:; quit;
