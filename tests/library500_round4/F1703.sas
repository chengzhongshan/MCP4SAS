/* F1703 corr_covariance, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1703a; do x=1 to 4; y=3*x; output; end; run;
proc corr data=f1703a outp=f1703b cov noprint; var x y; run;
data f1703o; set f1703b; if _type_='COV' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1703o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1703 rows=' rows;
else do; set f1703o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND4_PASS=F1703';
else put 'ERROR: ROUND4_FAIL=F1703 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1703:; quit;
