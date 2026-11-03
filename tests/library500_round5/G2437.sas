/* G2437 inc_temporary_fileref, N=8; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:338 */

filename rtemp temp;
data _null_; file rtemp; put 'data g2437o; actual=8*7; run;'; run;
%inc rtemp;
filename rtemp clear;

data _null_; if 0 then set g2437o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2437 rows=' rows;
else do; set g2437o; if not missing(actual) and abs(actual-(56))<=1e-9*max(1,abs(56)) then put 'ROUND5_PASS=G2437';
else put 'ERROR: ROUND5_FAIL=G2437 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2437:; quit;
