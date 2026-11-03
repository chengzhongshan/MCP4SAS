/* G2436 inc_temporary_fileref, N=7; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:338 */

filename rtemp temp;
data _null_; file rtemp; put 'data g2436o; actual=7*7; run;'; run;
%inc rtemp;
filename rtemp clear;

data _null_; if 0 then set g2436o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2436 rows=' rows;
else do; set g2436o; if not missing(actual) and abs(actual-(49))<=1e-9*max(1,abs(49)) then put 'ROUND5_PASS=G2436';
else put 'ERROR: ROUND5_FAIL=G2436 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2436:; quit;
