/* G2448 inc_two_filerefs, N=9; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:338 */

filename inc1 temp; filename inc2 temp;
data _null_; file inc1; put 'data g2448a; x=9; run;'; run;
data _null_; file inc2; put 'data g2448b; y=10; run;'; run;
%inc inc1 inc2;
filename inc1 clear; filename inc2 clear;
data g2448o; set g2448a; set g2448b; actual=x+y; run;

data _null_; if 0 then set g2448o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2448 rows=' rows;
else do; set g2448o; if not missing(actual) and abs(actual-(19))<=1e-9*max(1,abs(19)) then put 'ROUND5_PASS=G2448';
else put 'ERROR: ROUND5_FAIL=G2448 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2448:; quit;
