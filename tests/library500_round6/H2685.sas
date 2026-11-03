/* H2685 findw_case_insensitive, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:16 */

data h2685o; actual=6+findw('gene6 X','GENE6',' ','i'); run;

data _null_; if 0 then set h2685o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2685 rows=' rows;
else do; set h2685o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND6_PASS=H2685';
else put 'ERROR: ROUND6_FAIL=H2685 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2685:; quit;
