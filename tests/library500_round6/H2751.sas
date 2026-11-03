/* H2751 intnx_month_end, N=2; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2751o; actual=intnx('month','15DEC2019'd,2,'e'); run;

data _null_; if 0 then set h2751o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2751 rows=' rows;
else do; set h2751o; if not missing(actual) and abs(actual-(21974))<=1e-9*max(1,abs(21974)) then put 'ROUND6_PASS=H2751';
else put 'ERROR: ROUND6_FAIL=H2751 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2751:; quit;
