/* H2769 intnx_quarter_begin, N=10; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2769o; actual=intnx('qtr','15JAN2020'd,10,'b'); run;

data _null_; if 0 then set h2769o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2769 rows=' rows;
else do; set h2769o; if not missing(actual) and abs(actual-(22827))<=1e-9*max(1,abs(22827)) then put 'ROUND6_PASS=H2769';
else put 'ERROR: ROUND6_FAIL=H2769 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2769:; quit;
