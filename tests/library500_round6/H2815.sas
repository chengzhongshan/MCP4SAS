/* H2815 nwkdom_monday, N=6; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2815o; actual=nwkdom(1+mod(6,3),2,2,2020); run;

data _null_; if 0 then set h2815o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2815 rows=' rows;
else do; set h2815o; if not missing(actual) and abs(actual-(21948))<=1e-9*max(1,abs(21948)) then put 'ROUND6_PASS=H2815';
else put 'ERROR: ROUND6_FAIL=H2815 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2815:; quit;
