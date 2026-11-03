/* G2354 qsubstr_protected_comma, N=5; source: SAS-Useful-Codes/Macros/CD2CWD.sas:7 */

%let g2354text=%nrstr(a,b,5,z);
%let g2354part=%qsubstr(%superq(g2354text),5,1);
data g2354o; actual=input(symget('g2354part'),best32.); run;
%symdel g2354text g2354part;

data _null_; if 0 then set g2354o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2354 rows=' rows;
else do; set g2354o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2354';
else put 'ERROR: ROUND5_FAIL=G2354 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2354:; quit;
