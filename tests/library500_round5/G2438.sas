/* G2438 inc_temporary_fileref, N=9; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:338 */

filename rtemp temp;
data _null_; file rtemp; put 'data g2438o; actual=9*7; run;'; run;
%inc rtemp;
filename rtemp clear;

data _null_; if 0 then set g2438o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2438 rows=' rows;
else do; set g2438o; if not missing(actual) and abs(actual-(63))<=1e-9*max(1,abs(63)) then put 'ROUND5_PASS=G2438';
else put 'ERROR: ROUND5_FAIL=G2438 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2438:; quit;
