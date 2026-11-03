/* G2366 qupcase_literal_triggers, N=7; source: SAS-Useful-Codes/Macros/HpmixArray.sas:507 */

%let g2366text=%nrstr(a&bad%ghost7);
%let g2366upper=%qupcase(%superq(g2366text));
data g2366o; length text $50; text=symget('g2366upper'); actual=7*(text='A&BAD%GHOST7'); run;
%symdel g2366text g2366upper;

data _null_; if 0 then set g2366o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2366 rows=' rows;
else do; set g2366o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND5_PASS=G2366';
else put 'ERROR: ROUND5_FAIL=G2366 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2366:; quit;
