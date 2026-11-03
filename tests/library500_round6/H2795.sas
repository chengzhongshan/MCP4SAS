/* H2795 datejul_seven_digit, N=6; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2795o; actual=datejul(2020000+6); run;

data _null_; if 0 then set h2795o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2795 rows=' rows;
else do; set h2795o; if not missing(actual) and abs(actual-(21920))<=1e-9*max(1,abs(21920)) then put 'ROUND6_PASS=H2795';
else put 'ERROR: ROUND6_FAIL=H2795 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2795:; quit;
