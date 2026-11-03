/* G2413 macro_keyword_default_comma, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:1 */

%macro g2413m(list=%str(key,4)); %local part; %let part=%qscan(%superq(list),2,%str(,));
data g2413o; actual=input(symget('part'),best32.); run;
%mend; %g2413m(); %sysmacdelete g2413m;

data _null_; if 0 then set g2413o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2413 rows=' rows;
else do; set g2413o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND5_PASS=G2413';
else put 'ERROR: ROUND5_FAIL=G2413 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2413:; quit;
