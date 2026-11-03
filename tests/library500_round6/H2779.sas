/* H2779 intck_continuous_months, N=10; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */

data h2779o; start='15JAN2020'd; endpoint=intnx('month',start,10,'same')-1; actual=intck('month',start,endpoint,'c'); run;

data _null_; if 0 then set h2779o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2779 rows=' rows;
else do; set h2779o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND6_PASS=H2779';
else put 'ERROR: ROUND6_FAIL=H2779 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2779:; quit;
