/* T1485 fileref_assignment_status, N=6; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:76 */

filename rtemp temp;
data _null_; file rtemp; put 'owned status 6'; run;
data t1485a; active=fileref('rtemp'); run;
filename rtemp clear;
data t1485o; set t1485a; actual=6+(active=0)+(fileref('rtemp') ne 0); run;

data _null_; if 0 then set t1485o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1485 rows=' rows;
else do; set t1485o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1485';
else put 'ERROR: ROUND3_FAIL=T1485 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1485:; quit;
