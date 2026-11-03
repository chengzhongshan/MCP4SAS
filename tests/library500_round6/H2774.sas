/* H2774 intck_continuous_months, N=5; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */

data h2774o; start='15JAN2020'd; endpoint=intnx('month',start,5,'same')-1; actual=intck('month',start,endpoint,'c'); run;

data _null_; if 0 then set h2774o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2774 rows=' rows;
else do; set h2774o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND6_PASS=H2774';
else put 'ERROR: ROUND6_FAIL=H2774 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2774:; quit;
