/* G2440 inc_temporary_fileref, N=11; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:338 */

filename rtemp temp;
data _null_; file rtemp; put 'data g2440o; actual=11*7; run;'; run;
%inc rtemp;
filename rtemp clear;

data _null_; if 0 then set g2440o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2440 rows=' rows;
else do; set g2440o; if not missing(actual) and abs(actual-(77))<=1e-9*max(1,abs(77)) then put 'ROUND5_PASS=G2440';
else put 'ERROR: ROUND5_FAIL=G2440 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2440:; quit;
