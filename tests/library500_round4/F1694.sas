/* F1694 corr_spearman_tied_monotonic, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1694a; do x=1 to 5; y=x*x; output; output; end; run;
proc corr data=f1694a outs=f1694b spearman noprint; var x y; run;
data f1694o; set f1694b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1694o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1694 rows=' rows;
else do; set f1694o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1694';
else put 'ERROR: ROUND4_FAIL=F1694 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1694:; quit;
