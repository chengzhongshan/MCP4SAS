/* G2449 inc_two_filerefs, N=10; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:338 */

filename inc1 temp; filename inc2 temp;
data _null_; file inc1; put 'data g2449a; x=10; run;'; run;
data _null_; file inc2; put 'data g2449b; y=11; run;'; run;
%inc inc1 inc2;
filename inc1 clear; filename inc2 clear;
data g2449o; set g2449a; set g2449b; actual=x+y; run;

data _null_; if 0 then set g2449o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2449 rows=' rows;
else do; set g2449o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND5_PASS=G2449';
else put 'ERROR: ROUND5_FAIL=G2449 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2449:; quit;
