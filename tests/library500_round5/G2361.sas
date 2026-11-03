/* G2361 qupcase_literal_triggers, N=2; source: SAS-Useful-Codes/Macros/HpmixArray.sas:507 */

%let g2361text=%nrstr(a&bad%ghost2);
%let g2361upper=%qupcase(%superq(g2361text));
data g2361o; length text $50; text=symget('g2361upper'); actual=2*(text='A&BAD%GHOST2'); run;
%symdel g2361text g2361upper;

data _null_; if 0 then set g2361o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2361 rows=' rows;
else do; set g2361o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND5_PASS=G2361';
else put 'ERROR: ROUND5_FAIL=G2361 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2361:; quit;
