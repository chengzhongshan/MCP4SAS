/* T1483 fileref_assignment_status, N=4; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:76 */

filename rtemp temp;
data _null_; file rtemp; put 'owned status 4'; run;
data t1483a; active=fileref('rtemp'); run;
filename rtemp clear;
data t1483o; set t1483a; actual=4+(active=0)+(fileref('rtemp') ne 0); run;

data _null_; if 0 then set t1483o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1483 rows=' rows;
else do; set t1483o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1483';
else put 'ERROR: ROUND3_FAIL=T1483 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1483:; quit;
