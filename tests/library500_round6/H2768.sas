/* H2768 intnx_quarter_begin, N=9; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2768o; actual=intnx('qtr','15JAN2020'd,9,'b'); run;

data _null_; if 0 then set h2768o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2768 rows=' rows;
else do; set h2768o; if not missing(actual) and abs(actual-(22736))<=1e-9*max(1,abs(22736)) then put 'ROUND6_PASS=H2768';
else put 'ERROR: ROUND6_FAIL=H2768 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2768:; quit;
