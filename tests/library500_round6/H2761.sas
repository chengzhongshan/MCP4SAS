/* H2761 intnx_quarter_begin, N=2; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2761o; actual=intnx('qtr','15JAN2020'd,2,'b'); run;

data _null_; if 0 then set h2761o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2761 rows=' rows;
else do; set h2761o; if not missing(actual) and abs(actual-(22097))<=1e-9*max(1,abs(22097)) then put 'ROUND6_PASS=H2761';
else put 'ERROR: ROUND6_FAIL=H2761 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2761:; quit;
