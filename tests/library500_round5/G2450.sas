/* G2450 inc_two_filerefs, N=11; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:338 */

filename inc1 temp; filename inc2 temp;
data _null_; file inc1; put 'data g2450a; x=11; run;'; run;
data _null_; file inc2; put 'data g2450b; y=12; run;'; run;
%inc inc1 inc2;
filename inc1 clear; filename inc2 clear;
data g2450o; set g2450a; set g2450b; actual=x+y; run;

data _null_; if 0 then set g2450o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2450 rows=' rows;
else do; set g2450o; if not missing(actual) and abs(actual-(23))<=1e-9*max(1,abs(23)) then put 'ROUND5_PASS=G2450';
else put 'ERROR: ROUND5_FAIL=G2450 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2450:; quit;
