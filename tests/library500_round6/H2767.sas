/* H2767 intnx_quarter_begin, N=8; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2767o; actual=intnx('qtr','15JAN2020'd,8,'b'); run;

data _null_; if 0 then set h2767o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2767 rows=' rows;
else do; set h2767o; if not missing(actual) and abs(actual-(22646))<=1e-9*max(1,abs(22646)) then put 'ROUND6_PASS=H2767';
else put 'ERROR: ROUND6_FAIL=H2767 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2767:; quit;
