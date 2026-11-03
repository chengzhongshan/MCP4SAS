/* H2760 intnx_month_end, N=11; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2760o; actual=intnx('month','15DEC2019'd,11,'e'); run;

data _null_; if 0 then set h2760o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2760 rows=' rows;
else do; set h2760o; if not missing(actual) and abs(actual-(22249))<=1e-9*max(1,abs(22249)) then put 'ROUND6_PASS=H2760';
else put 'ERROR: ROUND6_FAIL=H2760 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2760:; quit;
