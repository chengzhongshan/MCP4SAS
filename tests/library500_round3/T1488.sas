/* T1488 fileref_assignment_status, N=9; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:76 */

filename rtemp temp;
data _null_; file rtemp; put 'owned status 9'; run;
data t1488a; active=fileref('rtemp'); run;
filename rtemp clear;
data t1488o; set t1488a; actual=9+(active=0)+(fileref('rtemp') ne 0); run;

data _null_; if 0 then set t1488o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1488 rows=' rows;
else do; set t1488o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND3_PASS=T1488';
else put 'ERROR: ROUND3_FAIL=T1488 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1488:; quit;
