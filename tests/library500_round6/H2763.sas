/* H2763 intnx_quarter_begin, N=4; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2763o; actual=intnx('qtr','15JAN2020'd,4,'b'); run;

data _null_; if 0 then set h2763o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2763 rows=' rows;
else do; set h2763o; if not missing(actual) and abs(actual-(22281))<=1e-9*max(1,abs(22281)) then put 'ROUND6_PASS=H2763';
else put 'ERROR: ROUND6_FAIL=H2763 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2763:; quit;
