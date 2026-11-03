/* G2357 qsubstr_protected_comma, N=8; source: SAS-Useful-Codes/Macros/CD2CWD.sas:7 */

%let g2357text=%nrstr(a,b,8,z);
%let g2357part=%qsubstr(%superq(g2357text),5,1);
data g2357o; actual=input(symget('g2357part'),best32.); run;
%symdel g2357text g2357part;

data _null_; if 0 then set g2357o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2357 rows=' rows;
else do; set g2357o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2357';
else put 'ERROR: ROUND5_FAIL=G2357 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2357:; quit;
