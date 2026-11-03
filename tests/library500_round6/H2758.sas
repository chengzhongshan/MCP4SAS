/* H2758 intnx_month_end, N=9; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2758o; actual=intnx('month','15DEC2019'd,9,'e'); run;

data _null_; if 0 then set h2758o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2758 rows=' rows;
else do; set h2758o; if not missing(actual) and abs(actual-(22188))<=1e-9*max(1,abs(22188)) then put 'ROUND6_PASS=H2758';
else put 'ERROR: ROUND6_FAIL=H2758 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2758:; quit;
