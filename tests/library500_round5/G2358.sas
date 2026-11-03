/* G2358 qsubstr_protected_comma, N=9; source: SAS-Useful-Codes/Macros/CD2CWD.sas:7 */

%let g2358text=%nrstr(a,b,9,z);
%let g2358part=%qsubstr(%superq(g2358text),5,1);
data g2358o; actual=input(symget('g2358part'),best32.); run;
%symdel g2358text g2358part;

data _null_; if 0 then set g2358o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2358 rows=' rows;
else do; set g2358o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2358';
else put 'ERROR: ROUND5_FAIL=G2358 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2358:; quit;
