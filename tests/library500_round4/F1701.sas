/* F1701 corr_covariance, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1701a; do x=1 to 2; y=3*x; output; end; run;
proc corr data=f1701a outp=f1701b cov noprint; var x y; run;
data f1701o; set f1701b; if _type_='COV' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1701o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1701 rows=' rows;
else do; set f1701o; if not missing(actual) and abs(actual-(1.5))<=1e-9*max(1,abs(1.5)) then put 'ROUND4_PASS=F1701';
else put 'ERROR: ROUND4_FAIL=F1701 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1701:; quit;
