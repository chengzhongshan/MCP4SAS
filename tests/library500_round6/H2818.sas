/* H2818 nwkdom_monday, N=9; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2818o; actual=nwkdom(1+mod(9,3),2,2,2020); run;

data _null_; if 0 then set h2818o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2818 rows=' rows;
else do; set h2818o; if not missing(actual) and abs(actual-(21948))<=1e-9*max(1,abs(21948)) then put 'ROUND6_PASS=H2818';
else put 'ERROR: ROUND6_FAIL=H2818 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2818:; quit;
