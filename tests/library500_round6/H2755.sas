/* H2755 intnx_month_end, N=6; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2755o; actual=intnx('month','15DEC2019'd,6,'e'); run;

data _null_; if 0 then set h2755o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2755 rows=' rows;
else do; set h2755o; if not missing(actual) and abs(actual-(22096))<=1e-9*max(1,abs(22096)) then put 'ROUND6_PASS=H2755';
else put 'ERROR: ROUND6_FAIL=H2755 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2755:; quit;
