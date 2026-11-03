/* G2446 inc_two_filerefs, N=7; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:338 */

filename inc1 temp; filename inc2 temp;
data _null_; file inc1; put 'data g2446a; x=7; run;'; run;
data _null_; file inc2; put 'data g2446b; y=8; run;'; run;
%inc inc1 inc2;
filename inc1 clear; filename inc2 clear;
data g2446o; set g2446a; set g2446b; actual=x+y; run;

data _null_; if 0 then set g2446o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2446 rows=' rows;
else do; set g2446o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND5_PASS=G2446';
else put 'ERROR: ROUND5_FAIL=G2446 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2446:; quit;
