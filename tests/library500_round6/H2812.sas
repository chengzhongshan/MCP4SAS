/* H2812 nwkdom_monday, N=3; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2812o; actual=nwkdom(1+mod(3,3),2,2,2020); run;

data _null_; if 0 then set h2812o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2812 rows=' rows;
else do; set h2812o; if not missing(actual) and abs(actual-(21948))<=1e-9*max(1,abs(21948)) then put 'ROUND6_PASS=H2812';
else put 'ERROR: ROUND6_FAIL=H2812 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2812:; quit;
