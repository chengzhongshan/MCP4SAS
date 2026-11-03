/* H2754 intnx_month_end, N=5; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2754o; actual=intnx('month','15DEC2019'd,5,'e'); run;

data _null_; if 0 then set h2754o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2754 rows=' rows;
else do; set h2754o; if not missing(actual) and abs(actual-(22066))<=1e-9*max(1,abs(22066)) then put 'ROUND6_PASS=H2754';
else put 'ERROR: ROUND6_FAIL=H2754 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2754:; quit;
