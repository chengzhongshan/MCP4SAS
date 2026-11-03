/* H2766 intnx_quarter_begin, N=7; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2766o; actual=intnx('qtr','15JAN2020'd,7,'b'); run;

data _null_; if 0 then set h2766o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2766 rows=' rows;
else do; set h2766o; if not missing(actual) and abs(actual-(22554))<=1e-9*max(1,abs(22554)) then put 'ROUND6_PASS=H2766';
else put 'ERROR: ROUND6_FAIL=H2766 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2766:; quit;
