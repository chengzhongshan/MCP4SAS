/* H2752 intnx_month_end, N=3; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2752o; actual=intnx('month','15DEC2019'd,3,'e'); run;

data _null_; if 0 then set h2752o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2752 rows=' rows;
else do; set h2752o; if not missing(actual) and abs(actual-(22005))<=1e-9*max(1,abs(22005)) then put 'ROUND6_PASS=H2752';
else put 'ERROR: ROUND6_FAIL=H2752 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2752:; quit;
