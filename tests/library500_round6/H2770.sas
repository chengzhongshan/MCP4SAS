/* H2770 intnx_quarter_begin, N=11; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2770o; actual=intnx('qtr','15JAN2020'd,11,'b'); run;

data _null_; if 0 then set h2770o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2770 rows=' rows;
else do; set h2770o; if not missing(actual) and abs(actual-(22919))<=1e-9*max(1,abs(22919)) then put 'ROUND6_PASS=H2770';
else put 'ERROR: ROUND6_FAIL=H2770 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2770:; quit;
