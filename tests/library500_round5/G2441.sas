/* G2441 inc_two_filerefs, N=2; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:338 */

filename inc1 temp; filename inc2 temp;
data _null_; file inc1; put 'data g2441a; x=2; run;'; run;
data _null_; file inc2; put 'data g2441b; y=3; run;'; run;
%inc inc1 inc2;
filename inc1 clear; filename inc2 clear;
data g2441o; set g2441a; set g2441b; actual=x+y; run;

data _null_; if 0 then set g2441o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2441 rows=' rows;
else do; set g2441o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2441';
else put 'ERROR: ROUND5_FAIL=G2441 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2441:; quit;
