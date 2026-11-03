/* G2363 qupcase_literal_triggers, N=4; source: SAS-Useful-Codes/Macros/HpmixArray.sas:507 */

%let g2363text=%nrstr(a&bad%ghost4);
%let g2363upper=%qupcase(%superq(g2363text));
data g2363o; length text $50; text=symget('g2363upper'); actual=4*(text='A&BAD%GHOST4'); run;
%symdel g2363text g2363upper;

data _null_; if 0 then set g2363o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2363 rows=' rows;
else do; set g2363o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND5_PASS=G2363';
else put 'ERROR: ROUND5_FAIL=G2363 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2363:; quit;
