/* H2780 intck_continuous_months, N=11; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */

data h2780o; start='15JAN2020'd; endpoint=intnx('month',start,11,'same')-1; actual=intck('month',start,endpoint,'c'); run;

data _null_; if 0 then set h2780o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2780 rows=' rows;
else do; set h2780o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND6_PASS=H2780';
else put 'ERROR: ROUND6_FAIL=H2780 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2780:; quit;
