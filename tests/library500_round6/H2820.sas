/* H2820 nwkdom_monday, N=11; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2820o; actual=nwkdom(1+mod(11,3),2,2,2020); run;

data _null_; if 0 then set h2820o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2820 rows=' rows;
else do; set h2820o; if not missing(actual) and abs(actual-(21962))<=1e-9*max(1,abs(21962)) then put 'ROUND6_PASS=H2820';
else put 'ERROR: ROUND6_FAIL=H2820 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2820:; quit;
