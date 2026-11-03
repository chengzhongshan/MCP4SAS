/* H2759 intnx_month_end, N=10; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2759o; actual=intnx('month','15DEC2019'd,10,'e'); run;

data _null_; if 0 then set h2759o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2759 rows=' rows;
else do; set h2759o; if not missing(actual) and abs(actual-(22219))<=1e-9*max(1,abs(22219)) then put 'ROUND6_PASS=H2759';
else put 'ERROR: ROUND6_FAIL=H2759 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2759:; quit;
