/* T1484 fileref_assignment_status, N=5; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:76 */

filename rtemp temp;
data _null_; file rtemp; put 'owned status 5'; run;
data t1484a; active=fileref('rtemp'); run;
filename rtemp clear;
data t1484o; set t1484a; actual=5+(active=0)+(fileref('rtemp') ne 0); run;

data _null_; if 0 then set t1484o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1484 rows=' rows;
else do; set t1484o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1484';
else put 'ERROR: ROUND3_FAIL=T1484 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1484:; quit;
