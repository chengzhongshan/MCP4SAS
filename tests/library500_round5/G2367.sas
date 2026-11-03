/* G2367 qupcase_literal_triggers, N=8; source: SAS-Useful-Codes/Macros/HpmixArray.sas:507 */

%let g2367text=%nrstr(a&bad%ghost8);
%let g2367upper=%qupcase(%superq(g2367text));
data g2367o; length text $50; text=symget('g2367upper'); actual=8*(text='A&BAD%GHOST8'); run;
%symdel g2367text g2367upper;

data _null_; if 0 then set g2367o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2367 rows=' rows;
else do; set g2367o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2367';
else put 'ERROR: ROUND5_FAIL=G2367 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2367:; quit;
