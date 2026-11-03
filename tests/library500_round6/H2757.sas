/* H2757 intnx_month_end, N=8; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2757o; actual=intnx('month','15DEC2019'd,8,'e'); run;

data _null_; if 0 then set h2757o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2757 rows=' rows;
else do; set h2757o; if not missing(actual) and abs(actual-(22158))<=1e-9*max(1,abs(22158)) then put 'ROUND6_PASS=H2757';
else put 'ERROR: ROUND6_FAIL=H2757 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2757:; quit;
