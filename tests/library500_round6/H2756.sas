/* H2756 intnx_month_end, N=7; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2756o; actual=intnx('month','15DEC2019'd,7,'e'); run;

data _null_; if 0 then set h2756o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2756 rows=' rows;
else do; set h2756o; if not missing(actual) and abs(actual-(22127))<=1e-9*max(1,abs(22127)) then put 'ROUND6_PASS=H2756';
else put 'ERROR: ROUND6_FAIL=H2756 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2756:; quit;
