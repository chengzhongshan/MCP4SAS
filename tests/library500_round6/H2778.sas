/* H2778 intck_continuous_months, N=9; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */

data h2778o; start='15JAN2020'd; endpoint=intnx('month',start,9,'same')-1; actual=intck('month',start,endpoint,'c'); run;

data _null_; if 0 then set h2778o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2778 rows=' rows;
else do; set h2778o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND6_PASS=H2778';
else put 'ERROR: ROUND6_FAIL=H2778 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2778:; quit;
