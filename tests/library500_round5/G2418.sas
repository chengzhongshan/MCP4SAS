/* G2418 macro_keyword_default_comma, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:1 */

%macro g2418m(list=%str(key,9)); %local part; %let part=%qscan(%superq(list),2,%str(,));
data g2418o; actual=input(symget('part'),best32.); run;
%mend; %g2418m(); %sysmacdelete g2418m;

data _null_; if 0 then set g2418o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2418 rows=' rows;
else do; set g2418o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2418';
else put 'ERROR: ROUND5_FAIL=G2418 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2418:; quit;
