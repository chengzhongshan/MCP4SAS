/* G2369 qupcase_literal_triggers, N=10; source: SAS-Useful-Codes/Macros/HpmixArray.sas:507 */

%let g2369text=%nrstr(a&bad%ghost10);
%let g2369upper=%qupcase(%superq(g2369text));
data g2369o; length text $50; text=symget('g2369upper'); actual=10*(text='A&BAD%GHOST10'); run;
%symdel g2369text g2369upper;

data _null_; if 0 then set g2369o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2369 rows=' rows;
else do; set g2369o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND5_PASS=G2369';
else put 'ERROR: ROUND5_FAIL=G2369 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2369:; quit;
