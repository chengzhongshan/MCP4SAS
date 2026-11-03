/* T1487 fileref_assignment_status, N=8; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:76 */

filename rtemp temp;
data _null_; file rtemp; put 'owned status 8'; run;
data t1487a; active=fileref('rtemp'); run;
filename rtemp clear;
data t1487o; set t1487a; actual=8+(active=0)+(fileref('rtemp') ne 0); run;

data _null_; if 0 then set t1487o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1487 rows=' rows;
else do; set t1487o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1487';
else put 'ERROR: ROUND3_FAIL=T1487 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1487:; quit;
