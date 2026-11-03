/* R962 call_execute_deferred, N=3; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:291 */

data _null_; call execute('data r962a; do x=1 to 3; output; end; run;'); run;
proc sql; create table r962o as select sum(x*x) as actual from r962a; quit;

data _null_; if 0 then set r962o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R962 rows=' rows;
else do; set r962o; if not missing(actual) and abs(actual-(14))<=1e-10*max(1,abs(14)) then put 'ROUND2_PASS=R962';
else put 'ERROR: ROUND2_FAIL=R962 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r962:; quit;
