/* G2368 qupcase_literal_triggers, N=9; source: SAS-Useful-Codes/Macros/HpmixArray.sas:507 */

%let g2368text=%nrstr(a&bad%ghost9);
%let g2368upper=%qupcase(%superq(g2368text));
data g2368o; length text $50; text=symget('g2368upper'); actual=9*(text='A&BAD%GHOST9'); run;
%symdel g2368text g2368upper;

data _null_; if 0 then set g2368o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2368 rows=' rows;
else do; set g2368o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2368';
else put 'ERROR: ROUND5_FAIL=G2368 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2368:; quit;
