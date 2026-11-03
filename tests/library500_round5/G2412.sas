/* G2412 macro_keyword_default_comma, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:1 */

%macro g2412m(list=%str(key,3)); %local part; %let part=%qscan(%superq(list),2,%str(,));
data g2412o; actual=input(symget('part'),best32.); run;
%mend; %g2412m(); %sysmacdelete g2412m;

data _null_; if 0 then set g2412o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2412 rows=' rows;
else do; set g2412o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2412';
else put 'ERROR: ROUND5_FAIL=G2412 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2412:; quit;
