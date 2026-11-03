/* R965 call_execute_deferred, N=6; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:291 */

data _null_; call execute('data r965a; do x=1 to 6; output; end; run;'); run;
proc sql; create table r965o as select sum(x*x) as actual from r965a; quit;

data _null_; if 0 then set r965o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R965 rows=' rows;
else do; set r965o; if not missing(actual) and abs(actual-(91))<=1e-10*max(1,abs(91)) then put 'ROUND2_PASS=R965';
else put 'ERROR: ROUND2_FAIL=R965 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r965:; quit;
