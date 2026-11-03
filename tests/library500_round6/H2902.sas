/* H2902 call_execute_double_quoted_include, N=3; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:291 */

filename rtemp temp;
data _null_; file rtemp; put 'data h2902a; value=3; run;'; run;
data _null_; call execute("%include rtemp;"); run;
filename rtemp clear;
data h2902o; set h2902a; actual=value; run;

data _null_; if 0 then set h2902o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2902 rows=' rows;
else do; set h2902o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND6_PASS=H2902';
else put 'ERROR: ROUND6_FAIL=H2902 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2902:; quit;
