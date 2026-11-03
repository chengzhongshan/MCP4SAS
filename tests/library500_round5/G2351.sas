/* G2351 qsubstr_protected_comma, N=2; source: SAS-Useful-Codes/Macros/CD2CWD.sas:7 */

%let g2351text=%nrstr(a,b,2,z);
%let g2351part=%qsubstr(%superq(g2351text),5,1);
data g2351o; actual=input(symget('g2351part'),best32.); run;
%symdel g2351text g2351part;

data _null_; if 0 then set g2351o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2351 rows=' rows;
else do; set g2351o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND5_PASS=G2351';
else put 'ERROR: ROUND5_FAIL=G2351 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2351:; quit;
