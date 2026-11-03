/* R968 call_execute_deferred, N=9; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:291 */

data _null_; call execute('data r968a; do x=1 to 9; output; end; run;'); run;
proc sql; create table r968o as select sum(x*x) as actual from r968a; quit;

data _null_; if 0 then set r968o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R968 rows=' rows;
else do; set r968o; if not missing(actual) and abs(actual-(285))<=1e-10*max(1,abs(285)) then put 'ROUND2_PASS=R968';
else put 'ERROR: ROUND2_FAIL=R968 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r968:; quit;
