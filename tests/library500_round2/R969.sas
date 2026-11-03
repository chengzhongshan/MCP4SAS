/* R969 call_execute_deferred, N=10; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:291 */

data _null_; call execute('data r969a; do x=1 to 10; output; end; run;'); run;
proc sql; create table r969o as select sum(x*x) as actual from r969a; quit;

data _null_; if 0 then set r969o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R969 rows=' rows;
else do; set r969o; if not missing(actual) and abs(actual-(385))<=1e-10*max(1,abs(385)) then put 'ROUND2_PASS=R969';
else put 'ERROR: ROUND2_FAIL=R969 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r969:; quit;
