/* G2414 macro_keyword_default_comma, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:1 */

%macro g2414m(list=%str(key,5)); %local part; %let part=%qscan(%superq(list),2,%str(,));
data g2414o; actual=input(symget('part'),best32.); run;
%mend; %g2414m(); %sysmacdelete g2414m;

data _null_; if 0 then set g2414o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2414 rows=' rows;
else do; set g2414o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2414';
else put 'ERROR: ROUND5_FAIL=G2414 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2414:; quit;
