/* H2843 dhms_attach_date, N=4; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2843o; date='01JAN2020'd+4; actual=dhms(date,1,2,3)-date*86400; run;

data _null_; if 0 then set h2843o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2843 rows=' rows;
else do; set h2843o; if not missing(actual) and abs(actual-(3723))<=1e-9*max(1,abs(3723)) then put 'ROUND6_PASS=H2843';
else put 'ERROR: ROUND6_FAIL=H2843 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2843:; quit;
