/* G2420 macro_keyword_default_comma, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:1 */

%macro g2420m(list=%str(key,11)); %local part; %let part=%qscan(%superq(list),2,%str(,));
data g2420o; actual=input(symget('part'),best32.); run;
%mend; %g2420m(); %sysmacdelete g2420m;

data _null_; if 0 then set g2420o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2420 rows=' rows;
else do; set g2420o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND5_PASS=G2420';
else put 'ERROR: ROUND5_FAIL=G2420 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2420:; quit;
