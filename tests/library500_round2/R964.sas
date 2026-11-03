/* R964 call_execute_deferred, N=5; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:291 */

data _null_; call execute('data r964a; do x=1 to 5; output; end; run;'); run;
proc sql; create table r964o as select sum(x*x) as actual from r964a; quit;

data _null_; if 0 then set r964o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R964 rows=' rows;
else do; set r964o; if not missing(actual) and abs(actual-(55))<=1e-10*max(1,abs(55)) then put 'ROUND2_PASS=R964';
else put 'ERROR: ROUND2_FAIL=R964 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r964:; quit;
