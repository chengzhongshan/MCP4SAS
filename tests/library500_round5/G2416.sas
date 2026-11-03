/* G2416 macro_keyword_default_comma, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:1 */

%macro g2416m(list=%str(key,7)); %local part; %let part=%qscan(%superq(list),2,%str(,));
data g2416o; actual=input(symget('part'),best32.); run;
%mend; %g2416m(); %sysmacdelete g2416m;

data _null_; if 0 then set g2416o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2416 rows=' rows;
else do; set g2416o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND5_PASS=G2416';
else put 'ERROR: ROUND5_FAIL=G2416 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2416:; quit;
