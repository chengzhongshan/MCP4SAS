/* F1710 corr_covariance, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1710a; do x=1 to 11; y=3*x; output; end; run;
proc corr data=f1710a outp=f1710b cov noprint; var x y; run;
data f1710o; set f1710b; if _type_='COV' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1710o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1710 rows=' rows;
else do; set f1710o; if not missing(actual) and abs(actual-(33))<=1e-9*max(1,abs(33)) then put 'ROUND4_PASS=F1710';
else put 'ERROR: ROUND4_FAIL=F1710 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1710:; quit;
