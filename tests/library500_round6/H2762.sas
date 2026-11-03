/* H2762 intnx_quarter_begin, N=3; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2762o; actual=intnx('qtr','15JAN2020'd,3,'b'); run;

data _null_; if 0 then set h2762o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2762 rows=' rows;
else do; set h2762o; if not missing(actual) and abs(actual-(22189))<=1e-9*max(1,abs(22189)) then put 'ROUND6_PASS=H2762';
else put 'ERROR: ROUND6_FAIL=H2762 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2762:; quit;
