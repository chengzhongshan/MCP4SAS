/* G2353 qsubstr_protected_comma, N=4; source: SAS-Useful-Codes/Macros/CD2CWD.sas:7 */

%let g2353text=%nrstr(a,b,4,z);
%let g2353part=%qsubstr(%superq(g2353text),5,1);
data g2353o; actual=input(symget('g2353part'),best32.); run;
%symdel g2353text g2353part;

data _null_; if 0 then set g2353o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2353 rows=' rows;
else do; set g2353o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND5_PASS=G2353';
else put 'ERROR: ROUND5_FAIL=G2353 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2353:; quit;
