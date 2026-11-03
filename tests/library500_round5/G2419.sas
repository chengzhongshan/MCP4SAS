/* G2419 macro_keyword_default_comma, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:1 */

%macro g2419m(list=%str(key,10)); %local part; %let part=%qscan(%superq(list),2,%str(,));
data g2419o; actual=input(symget('part'),best32.); run;
%mend; %g2419m(); %sysmacdelete g2419m;

data _null_; if 0 then set g2419o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2419 rows=' rows;
else do; set g2419o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND5_PASS=G2419';
else put 'ERROR: ROUND5_FAIL=G2419 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2419:; quit;
