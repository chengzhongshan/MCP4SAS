/* T1486 fileref_assignment_status, N=7; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:76 */

filename rtemp temp;
data _null_; file rtemp; put 'owned status 7'; run;
data t1486a; active=fileref('rtemp'); run;
filename rtemp clear;
data t1486o; set t1486a; actual=7+(active=0)+(fileref('rtemp') ne 0); run;

data _null_; if 0 then set t1486o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1486 rows=' rows;
else do; set t1486o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1486';
else put 'ERROR: ROUND3_FAIL=T1486 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1486:; quit;
