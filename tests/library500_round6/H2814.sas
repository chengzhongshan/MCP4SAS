/* H2814 nwkdom_monday, N=5; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2814o; actual=nwkdom(1+mod(5,3),2,2,2020); run;

data _null_; if 0 then set h2814o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2814 rows=' rows;
else do; set h2814o; if not missing(actual) and abs(actual-(21962))<=1e-9*max(1,abs(21962)) then put 'ROUND6_PASS=H2814';
else put 'ERROR: ROUND6_FAIL=H2814 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2814:; quit;
