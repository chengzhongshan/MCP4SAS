/* G2411 macro_keyword_default_comma, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:1 */

%macro g2411m(list=%str(key,2)); %local part; %let part=%qscan(%superq(list),2,%str(,));
data g2411o; actual=input(symget('part'),best32.); run;
%mend; %g2411m(); %sysmacdelete g2411m;

data _null_; if 0 then set g2411o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2411 rows=' rows;
else do; set g2411o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND5_PASS=G2411';
else put 'ERROR: ROUND5_FAIL=G2411 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2411:; quit;
