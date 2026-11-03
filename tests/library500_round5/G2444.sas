/* G2444 inc_two_filerefs, N=5; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:338 */

filename inc1 temp; filename inc2 temp;
data _null_; file inc1; put 'data g2444a; x=5; run;'; run;
data _null_; file inc2; put 'data g2444b; y=6; run;'; run;
%inc inc1 inc2;
filename inc1 clear; filename inc2 clear;
data g2444o; set g2444a; set g2444b; actual=x+y; run;

data _null_; if 0 then set g2444o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2444 rows=' rows;
else do; set g2444o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND5_PASS=G2444';
else put 'ERROR: ROUND5_FAIL=G2444 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2444:; quit;
