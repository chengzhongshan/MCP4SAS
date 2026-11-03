/* G2447 inc_two_filerefs, N=8; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:338 */

filename inc1 temp; filename inc2 temp;
data _null_; file inc1; put 'data g2447a; x=8; run;'; run;
data _null_; file inc2; put 'data g2447b; y=9; run;'; run;
%inc inc1 inc2;
filename inc1 clear; filename inc2 clear;
data g2447o; set g2447a; set g2447b; actual=x+y; run;

data _null_; if 0 then set g2447o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2447 rows=' rows;
else do; set g2447o; if not missing(actual) and abs(actual-(17))<=1e-9*max(1,abs(17)) then put 'ROUND5_PASS=G2447';
else put 'ERROR: ROUND5_FAIL=G2447 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2447:; quit;
