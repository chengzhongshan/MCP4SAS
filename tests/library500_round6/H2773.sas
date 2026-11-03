/* H2773 intck_continuous_months, N=4; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */

data h2773o; start='15JAN2020'd; endpoint=intnx('month',start,4,'same')-1; actual=intck('month',start,endpoint,'c'); run;

data _null_; if 0 then set h2773o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2773 rows=' rows;
else do; set h2773o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND6_PASS=H2773';
else put 'ERROR: ROUND6_FAIL=H2773 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2773:; quit;
