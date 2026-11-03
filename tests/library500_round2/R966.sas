/* R966 call_execute_deferred, N=7; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:291 */

data _null_; call execute('data r966a; do x=1 to 7; output; end; run;'); run;
proc sql; create table r966o as select sum(x*x) as actual from r966a; quit;

data _null_; if 0 then set r966o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R966 rows=' rows;
else do; set r966o; if not missing(actual) and abs(actual-(140))<=1e-10*max(1,abs(140)) then put 'ROUND2_PASS=R966';
else put 'ERROR: ROUND2_FAIL=R966 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r966:; quit;
