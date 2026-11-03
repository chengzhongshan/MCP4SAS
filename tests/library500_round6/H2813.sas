/* H2813 nwkdom_monday, N=4; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2813o; actual=nwkdom(1+mod(4,3),2,2,2020); run;

data _null_; if 0 then set h2813o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2813 rows=' rows;
else do; set h2813o; if not missing(actual) and abs(actual-(21955))<=1e-9*max(1,abs(21955)) then put 'ROUND6_PASS=H2813';
else put 'ERROR: ROUND6_FAIL=H2813 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2813:; quit;
