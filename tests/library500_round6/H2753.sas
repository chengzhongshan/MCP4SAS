/* H2753 intnx_month_end, N=4; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2753o; actual=intnx('month','15DEC2019'd,4,'e'); run;

data _null_; if 0 then set h2753o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2753 rows=' rows;
else do; set h2753o; if not missing(actual) and abs(actual-(22035))<=1e-9*max(1,abs(22035)) then put 'ROUND6_PASS=H2753';
else put 'ERROR: ROUND6_FAIL=H2753 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2753:; quit;
