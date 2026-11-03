/* H2765 intnx_quarter_begin, N=6; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2765o; actual=intnx('qtr','15JAN2020'd,6,'b'); run;

data _null_; if 0 then set h2765o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2765 rows=' rows;
else do; set h2765o; if not missing(actual) and abs(actual-(22462))<=1e-9*max(1,abs(22462)) then put 'ROUND6_PASS=H2765';
else put 'ERROR: ROUND6_FAIL=H2765 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2765:; quit;
