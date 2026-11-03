/* H2682 findw_case_insensitive, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:16 */

data h2682o; actual=3+findw('gene3 X','GENE3',' ','i'); run;

data _null_; if 0 then set h2682o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2682 rows=' rows;
else do; set h2682o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND6_PASS=H2682';
else put 'ERROR: ROUND6_FAIL=H2682 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2682:; quit;
