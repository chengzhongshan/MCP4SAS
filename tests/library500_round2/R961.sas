/* R961 call_execute_deferred, N=2; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:291 */

data _null_; call execute('data r961a; do x=1 to 2; output; end; run;'); run;
proc sql; create table r961o as select sum(x*x) as actual from r961a; quit;

data _null_; if 0 then set r961o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R961 rows=' rows;
else do; set r961o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND2_PASS=R961';
else put 'ERROR: ROUND2_FAIL=R961 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r961:; quit;
