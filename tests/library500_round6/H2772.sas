/* H2772 intck_continuous_months, N=3; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */

data h2772o; start='15JAN2020'd; endpoint=intnx('month',start,3,'same')-1; actual=intck('month',start,endpoint,'c'); run;

data _null_; if 0 then set h2772o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2772 rows=' rows;
else do; set h2772o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND6_PASS=H2772';
else put 'ERROR: ROUND6_FAIL=H2772 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2772:; quit;
