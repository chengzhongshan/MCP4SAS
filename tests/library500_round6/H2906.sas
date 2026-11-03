/* H2906 call_execute_double_quoted_include, N=7; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:291 */

filename rtemp temp;
data _null_; file rtemp; put 'data h2906a; value=7; run;'; run;
data _null_; call execute("%include rtemp;"); run;
filename rtemp clear;
data h2906o; set h2906a; actual=value; run;

data _null_; if 0 then set h2906o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2906 rows=' rows;
else do; set h2906o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND6_PASS=H2906';
else put 'ERROR: ROUND6_FAIL=H2906 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2906:; quit;
