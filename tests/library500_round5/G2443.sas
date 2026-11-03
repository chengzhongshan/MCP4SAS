/* G2443 inc_two_filerefs, N=4; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:338 */

filename inc1 temp; filename inc2 temp;
data _null_; file inc1; put 'data g2443a; x=4; run;'; run;
data _null_; file inc2; put 'data g2443b; y=5; run;'; run;
%inc inc1 inc2;
filename inc1 clear; filename inc2 clear;
data g2443o; set g2443a; set g2443b; actual=x+y; run;

data _null_; if 0 then set g2443o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2443 rows=' rows;
else do; set g2443o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2443';
else put 'ERROR: ROUND5_FAIL=G2443 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2443:; quit;
