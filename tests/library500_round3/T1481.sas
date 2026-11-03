/* T1481 fileref_assignment_status, N=2; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:76 */

filename rtemp temp;
data _null_; file rtemp; put 'owned status 2'; run;
data t1481a; active=fileref('rtemp'); run;
filename rtemp clear;
data t1481o; set t1481a; actual=2+(active=0)+(fileref('rtemp') ne 0); run;

data _null_; if 0 then set t1481o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1481 rows=' rows;
else do; set t1481o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND3_PASS=T1481';
else put 'ERROR: ROUND3_FAIL=T1481 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1481:; quit;
