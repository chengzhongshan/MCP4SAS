/* G2442 inc_two_filerefs, N=3; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:338 */

filename inc1 temp; filename inc2 temp;
data _null_; file inc1; put 'data g2442a; x=3; run;'; run;
data _null_; file inc2; put 'data g2442b; y=4; run;'; run;
%inc inc1 inc2;
filename inc1 clear; filename inc2 clear;
data g2442o; set g2442a; set g2442b; actual=x+y; run;

data _null_; if 0 then set g2442o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2442 rows=' rows;
else do; set g2442o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND5_PASS=G2442';
else put 'ERROR: ROUND5_FAIL=G2442 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2442:; quit;
