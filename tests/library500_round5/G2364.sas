/* G2364 qupcase_literal_triggers, N=5; source: SAS-Useful-Codes/Macros/HpmixArray.sas:507 */

%let g2364text=%nrstr(a&bad%ghost5);
%let g2364upper=%qupcase(%superq(g2364text));
data g2364o; length text $50; text=symget('g2364upper'); actual=5*(text='A&BAD%GHOST5'); run;
%symdel g2364text g2364upper;

data _null_; if 0 then set g2364o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2364 rows=' rows;
else do; set g2364o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2364';
else put 'ERROR: ROUND5_FAIL=G2364 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2364:; quit;
