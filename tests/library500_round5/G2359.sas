/* G2359 qsubstr_protected_comma, N=10; source: SAS-Useful-Codes/Macros/CD2CWD.sas:7 */

%let g2359text=%nrstr(a,b,10,z);
%let g2359part=%qsubstr(%superq(g2359text),5,2);
data g2359o; actual=input(symget('g2359part'),best32.); run;
%symdel g2359text g2359part;

data _null_; if 0 then set g2359o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2359 rows=' rows;
else do; set g2359o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND5_PASS=G2359';
else put 'ERROR: ROUND5_FAIL=G2359 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2359:; quit;
