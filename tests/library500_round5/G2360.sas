/* G2360 qsubstr_protected_comma, N=11; source: SAS-Useful-Codes/Macros/CD2CWD.sas:7 */

%let g2360text=%nrstr(a,b,11,z);
%let g2360part=%qsubstr(%superq(g2360text),5,2);
data g2360o; actual=input(symget('g2360part'),best32.); run;
%symdel g2360text g2360part;

data _null_; if 0 then set g2360o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2360 rows=' rows;
else do; set g2360o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND5_PASS=G2360';
else put 'ERROR: ROUND5_FAIL=G2360 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2360:; quit;
