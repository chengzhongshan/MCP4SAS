/* G2431 inc_temporary_fileref, N=2; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:338 */

filename rtemp temp;
data _null_; file rtemp; put 'data g2431o; actual=2*7; run;'; run;
%inc rtemp;
filename rtemp clear;

data _null_; if 0 then set g2431o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2431 rows=' rows;
else do; set g2431o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND5_PASS=G2431';
else put 'ERROR: ROUND5_FAIL=G2431 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2431:; quit;
