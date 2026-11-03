/* G2433 inc_temporary_fileref, N=4; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:338 */

filename rtemp temp;
data _null_; file rtemp; put 'data g2433o; actual=4*7; run;'; run;
%inc rtemp;
filename rtemp clear;

data _null_; if 0 then set g2433o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2433 rows=' rows;
else do; set g2433o; if not missing(actual) and abs(actual-(28))<=1e-9*max(1,abs(28)) then put 'ROUND5_PASS=G2433';
else put 'ERROR: ROUND5_FAIL=G2433 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2433:; quit;
