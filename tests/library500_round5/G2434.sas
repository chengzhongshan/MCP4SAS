/* G2434 inc_temporary_fileref, N=5; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:338 */

filename rtemp temp;
data _null_; file rtemp; put 'data g2434o; actual=5*7; run;'; run;
%inc rtemp;
filename rtemp clear;

data _null_; if 0 then set g2434o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2434 rows=' rows;
else do; set g2434o; if not missing(actual) and abs(actual-(35))<=1e-9*max(1,abs(35)) then put 'ROUND5_PASS=G2434';
else put 'ERROR: ROUND5_FAIL=G2434 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2434:; quit;
