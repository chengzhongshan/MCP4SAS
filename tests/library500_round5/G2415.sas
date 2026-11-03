/* G2415 macro_keyword_default_comma, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:1 */

%macro g2415m(list=%str(key,6)); %local part; %let part=%qscan(%superq(list),2,%str(,));
data g2415o; actual=input(symget('part'),best32.); run;
%mend; %g2415m(); %sysmacdelete g2415m;

data _null_; if 0 then set g2415o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2415 rows=' rows;
else do; set g2415o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND5_PASS=G2415';
else put 'ERROR: ROUND5_FAIL=G2415 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2415:; quit;
