/* G2355 qsubstr_protected_comma, N=6; source: SAS-Useful-Codes/Macros/CD2CWD.sas:7 */

%let g2355text=%nrstr(a,b,6,z);
%let g2355part=%qsubstr(%superq(g2355text),5,1);
data g2355o; actual=input(symget('g2355part'),best32.); run;
%symdel g2355text g2355part;

data _null_; if 0 then set g2355o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2355 rows=' rows;
else do; set g2355o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND5_PASS=G2355';
else put 'ERROR: ROUND5_FAIL=G2355 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2355:; quit;
