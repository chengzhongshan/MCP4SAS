/* H2764 intnx_quarter_begin, N=5; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2764o; actual=intnx('qtr','15JAN2020'd,5,'b'); run;

data _null_; if 0 then set h2764o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2764 rows=' rows;
else do; set h2764o; if not missing(actual) and abs(actual-(22371))<=1e-9*max(1,abs(22371)) then put 'ROUND6_PASS=H2764';
else put 'ERROR: ROUND6_FAIL=H2764 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2764:; quit;
