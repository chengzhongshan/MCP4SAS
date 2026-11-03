/* G2352 qsubstr_protected_comma, N=3; source: SAS-Useful-Codes/Macros/CD2CWD.sas:7 */

%let g2352text=%nrstr(a,b,3,z);
%let g2352part=%qsubstr(%superq(g2352text),5,1);
data g2352o; actual=input(symget('g2352part'),best32.); run;
%symdel g2352text g2352part;

data _null_; if 0 then set g2352o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2352 rows=' rows;
else do; set g2352o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2352';
else put 'ERROR: ROUND5_FAIL=G2352 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2352:; quit;
