/* T1482 fileref_assignment_status, N=3; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:76 */

filename rtemp temp;
data _null_; file rtemp; put 'owned status 3'; run;
data t1482a; active=fileref('rtemp'); run;
filename rtemp clear;
data t1482o; set t1482a; actual=3+(active=0)+(fileref('rtemp') ne 0); run;

data _null_; if 0 then set t1482o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1482 rows=' rows;
else do; set t1482o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1482';
else put 'ERROR: ROUND3_FAIL=T1482 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1482:; quit;
