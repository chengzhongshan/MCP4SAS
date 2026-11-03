/* F1693 corr_spearman_tied_monotonic, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:21 */

data f1693a; do x=1 to 4; y=x*x; output; output; end; run;
proc corr data=f1693a outs=f1693b spearman noprint; var x y; run;
data f1693o; set f1693b; if _type_='CORR' and upcase(_name_)='X'; actual=y; run;

data _null_; if 0 then set f1693o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1693 rows=' rows;
else do; set f1693o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1693';
else put 'ERROR: ROUND4_FAIL=F1693 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1693:; quit;
