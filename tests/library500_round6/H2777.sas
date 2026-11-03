/* H2777 intck_continuous_months, N=8; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */

data h2777o; start='15JAN2020'd; endpoint=intnx('month',start,8,'same')-1; actual=intck('month',start,endpoint,'c'); run;

data _null_; if 0 then set h2777o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2777 rows=' rows;
else do; set h2777o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND6_PASS=H2777';
else put 'ERROR: ROUND6_FAIL=H2777 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2777:; quit;
