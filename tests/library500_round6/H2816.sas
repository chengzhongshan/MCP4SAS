/* H2816 nwkdom_monday, N=7; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2816o; actual=nwkdom(1+mod(7,3),2,2,2020); run;

data _null_; if 0 then set h2816o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2816 rows=' rows;
else do; set h2816o; if not missing(actual) and abs(actual-(21955))<=1e-9*max(1,abs(21955)) then put 'ROUND6_PASS=H2816';
else put 'ERROR: ROUND6_FAIL=H2816 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2816:; quit;
