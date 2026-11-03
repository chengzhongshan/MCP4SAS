/* F1708 corr_covariance, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1708a; do x=1 to 9; y=3*x; output; end; run;
proc corr data=f1708a outp=f1708b cov noprint; var x y; run;
data f1708o; set f1708b; if _type_='COV' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1708o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1708 rows=' rows;
else do; set f1708o; if not missing(actual) and abs(actual-(22.5))<=1e-9*max(1,abs(22.5)) then put 'ROUND4_PASS=F1708';
else put 'ERROR: ROUND4_FAIL=F1708 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1708:; quit;
