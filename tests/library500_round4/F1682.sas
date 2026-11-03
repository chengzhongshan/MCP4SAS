/* F1682 corr_negative_affine, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1682a; do x=1 to 3+2; y=3-3*x; output; end; run;
proc corr data=f1682a outp=f1682b noprint; var x y; run;
data f1682o; set f1682b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1682o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1682 rows=' rows;
else do; set f1682o; if not missing(actual) and abs(actual-(-1))<=1e-9*max(1,abs(-1)) then put 'ROUND4_PASS=F1682';
else put 'ERROR: ROUND4_FAIL=F1682 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1682:; quit;
