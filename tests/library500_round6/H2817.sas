/* H2817 nwkdom_monday, N=8; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2817o; actual=nwkdom(1+mod(8,3),2,2,2020); run;

data _null_; if 0 then set h2817o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2817 rows=' rows;
else do; set h2817o; if not missing(actual) and abs(actual-(21962))<=1e-9*max(1,abs(21962)) then put 'ROUND6_PASS=H2817';
else put 'ERROR: ROUND6_FAIL=H2817 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2817:; quit;
