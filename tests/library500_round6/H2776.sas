/* H2776 intck_continuous_months, N=7; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */

data h2776o; start='15JAN2020'd; endpoint=intnx('month',start,7,'same')-1; actual=intck('month',start,endpoint,'c'); run;

data _null_; if 0 then set h2776o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2776 rows=' rows;
else do; set h2776o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND6_PASS=H2776';
else put 'ERROR: ROUND6_FAIL=H2776 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2776:; quit;
