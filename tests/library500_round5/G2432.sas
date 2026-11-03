/* G2432 inc_temporary_fileref, N=3; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:338 */

filename rtemp temp;
data _null_; file rtemp; put 'data g2432o; actual=3*7; run;'; run;
%inc rtemp;
filename rtemp clear;

data _null_; if 0 then set g2432o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2432 rows=' rows;
else do; set g2432o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND5_PASS=G2432';
else put 'ERROR: ROUND5_FAIL=G2432 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2432:; quit;
