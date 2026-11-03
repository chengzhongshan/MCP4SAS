/* G2439 inc_temporary_fileref, N=10; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:338 */

filename rtemp temp;
data _null_; file rtemp; put 'data g2439o; actual=10*7; run;'; run;
%inc rtemp;
filename rtemp clear;

data _null_; if 0 then set g2439o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2439 rows=' rows;
else do; set g2439o; if not missing(actual) and abs(actual-(70))<=1e-9*max(1,abs(70)) then put 'ROUND5_PASS=G2439';
else put 'ERROR: ROUND5_FAIL=G2439 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2439:; quit;
