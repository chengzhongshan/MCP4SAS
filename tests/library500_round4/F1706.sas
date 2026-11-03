/* F1706 corr_covariance, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1706a; do x=1 to 7; y=3*x; output; end; run;
proc corr data=f1706a outp=f1706b cov noprint; var x y; run;
data f1706o; set f1706b; if _type_='COV' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1706o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1706 rows=' rows;
else do; set f1706o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND4_PASS=F1706';
else put 'ERROR: ROUND4_FAIL=F1706 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1706:; quit;
