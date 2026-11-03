/* G2417 macro_keyword_default_comma, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:1 */

%macro g2417m(list=%str(key,8)); %local part; %let part=%qscan(%superq(list),2,%str(,));
data g2417o; actual=input(symget('part'),best32.); run;
%mend; %g2417m(); %sysmacdelete g2417m;

data _null_; if 0 then set g2417o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2417 rows=' rows;
else do; set g2417o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2417';
else put 'ERROR: ROUND5_FAIL=G2417 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2417:; quit;
