/* F1702 corr_covariance, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1702a; do x=1 to 3; y=3*x; output; end; run;
proc corr data=f1702a outp=f1702b cov noprint; var x y; run;
data f1702o; set f1702b; if _type_='COV' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1702o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1702 rows=' rows;
else do; set f1702o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND4_PASS=F1702';
else put 'ERROR: ROUND4_FAIL=F1702 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1702:; quit;
