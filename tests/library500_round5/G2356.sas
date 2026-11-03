/* G2356 qsubstr_protected_comma, N=7; source: SAS-Useful-Codes/Macros/CD2CWD.sas:7 */

%let g2356text=%nrstr(a,b,7,z);
%let g2356part=%qsubstr(%superq(g2356text),5,1);
data g2356o; actual=input(symget('g2356part'),best32.); run;
%symdel g2356text g2356part;

data _null_; if 0 then set g2356o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2356 rows=' rows;
else do; set g2356o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND5_PASS=G2356';
else put 'ERROR: ROUND5_FAIL=G2356 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2356:; quit;
