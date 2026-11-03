/* F1689 corr_negative_affine, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1689a; do x=1 to 10+2; y=10-3*x; output; end; run;
proc corr data=f1689a outp=f1689b noprint; var x y; run;
data f1689o; set f1689b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1689o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1689 rows=' rows;
else do; set f1689o; if not missing(actual) and abs(actual-(-1))<=1e-9*max(1,abs(-1)) then put 'ROUND4_PASS=F1689';
else put 'ERROR: ROUND4_FAIL=F1689 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1689:; quit;
