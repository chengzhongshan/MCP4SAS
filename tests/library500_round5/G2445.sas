/* G2445 inc_two_filerefs, N=6; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:338 */

filename inc1 temp; filename inc2 temp;
data _null_; file inc1; put 'data g2445a; x=6; run;'; run;
data _null_; file inc2; put 'data g2445b; y=7; run;'; run;
%inc inc1 inc2;
filename inc1 clear; filename inc2 clear;
data g2445o; set g2445a; set g2445b; actual=x+y; run;

data _null_; if 0 then set g2445o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2445 rows=' rows;
else do; set g2445o; if not missing(actual) and abs(actual-(13))<=1e-9*max(1,abs(13)) then put 'ROUND5_PASS=G2445';
else put 'ERROR: ROUND5_FAIL=G2445 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2445:; quit;
