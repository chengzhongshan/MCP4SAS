/* T1489 fileref_assignment_status, N=10; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:76 */

filename rtemp temp;
data _null_; file rtemp; put 'owned status 10'; run;
data t1489a; active=fileref('rtemp'); run;
filename rtemp clear;
data t1489o; set t1489a; actual=10+(active=0)+(fileref('rtemp') ne 0); run;

data _null_; if 0 then set t1489o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1489 rows=' rows;
else do; set t1489o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND3_PASS=T1489';
else put 'ERROR: ROUND3_FAIL=T1489 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1489:; quit;
