/* T1490 fileref_assignment_status, N=11; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:76 */

filename rtemp temp;
data _null_; file rtemp; put 'owned status 11'; run;
data t1490a; active=fileref('rtemp'); run;
filename rtemp clear;
data t1490o; set t1490a; actual=11+(active=0)+(fileref('rtemp') ne 0); run;

data _null_; if 0 then set t1490o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1490 rows=' rows;
else do; set t1490o; if not missing(actual) and abs(actual-(13))<=1e-10*max(1,abs(13)) then put 'ROUND3_PASS=T1490';
else put 'ERROR: ROUND3_FAIL=T1490 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1490:; quit;
