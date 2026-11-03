/* H2775 intck_continuous_months, N=6; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */

data h2775o; start='15JAN2020'd; endpoint=intnx('month',start,6,'same')-1; actual=intck('month',start,endpoint,'c'); run;

data _null_; if 0 then set h2775o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2775 rows=' rows;
else do; set h2775o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND6_PASS=H2775';
else put 'ERROR: ROUND6_FAIL=H2775 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2775:; quit;
