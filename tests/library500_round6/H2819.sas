/* H2819 nwkdom_monday, N=10; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2819o; actual=nwkdom(1+mod(10,3),2,2,2020); run;

data _null_; if 0 then set h2819o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2819 rows=' rows;
else do; set h2819o; if not missing(actual) and abs(actual-(21955))<=1e-9*max(1,abs(21955)) then put 'ROUND6_PASS=H2819';
else put 'ERROR: ROUND6_FAIL=H2819 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2819:; quit;
