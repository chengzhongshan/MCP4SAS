/* F1707 corr_covariance, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1707a; do x=1 to 8; y=3*x; output; end; run;
proc corr data=f1707a outp=f1707b cov noprint; var x y; run;
data f1707o; set f1707b; if _type_='COV' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1707o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1707 rows=' rows;
else do; set f1707o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND4_PASS=F1707';
else put 'ERROR: ROUND4_FAIL=F1707 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1707:; quit;
