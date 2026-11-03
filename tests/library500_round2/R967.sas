/* R967 call_execute_deferred, N=8; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:291 */

data _null_; call execute('data r967a; do x=1 to 8; output; end; run;'); run;
proc sql; create table r967o as select sum(x*x) as actual from r967a; quit;

data _null_; if 0 then set r967o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R967 rows=' rows;
else do; set r967o; if not missing(actual) and abs(actual-(204))<=1e-10*max(1,abs(204)) then put 'ROUND2_PASS=R967';
else put 'ERROR: ROUND2_FAIL=R967 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r967:; quit;
