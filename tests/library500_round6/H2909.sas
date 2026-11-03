/* H2909 call_execute_double_quoted_include, N=10; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:291 */

filename rtemp temp;
data _null_; file rtemp; put 'data h2909a; value=10; run;'; run;
data _null_; call execute("%include rtemp;"); run;
filename rtemp clear;
data h2909o; set h2909a; actual=value; run;

data _null_; if 0 then set h2909o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2909 rows=' rows;
else do; set h2909o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND6_PASS=H2909';
else put 'ERROR: ROUND6_FAIL=H2909 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2909:; quit;
