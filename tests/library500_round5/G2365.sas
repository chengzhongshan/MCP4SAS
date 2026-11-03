/* G2365 qupcase_literal_triggers, N=6; source: SAS-Useful-Codes/Macros/HpmixArray.sas:507 */

%let g2365text=%nrstr(a&bad%ghost6);
%let g2365upper=%qupcase(%superq(g2365text));
data g2365o; length text $50; text=symget('g2365upper'); actual=6*(text='A&BAD%GHOST6'); run;
%symdel g2365text g2365upper;

data _null_; if 0 then set g2365o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2365 rows=' rows;
else do; set g2365o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND5_PASS=G2365';
else put 'ERROR: ROUND5_FAIL=G2365 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2365:; quit;
