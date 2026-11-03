/* G2435 inc_temporary_fileref, N=6; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:338 */

filename rtemp temp;
data _null_; file rtemp; put 'data g2435o; actual=6*7; run;'; run;
%inc rtemp;
filename rtemp clear;

data _null_; if 0 then set g2435o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2435 rows=' rows;
else do; set g2435o; if not missing(actual) and abs(actual-(42))<=1e-9*max(1,abs(42)) then put 'ROUND5_PASS=G2435';
else put 'ERROR: ROUND5_FAIL=G2435 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2435:; quit;
