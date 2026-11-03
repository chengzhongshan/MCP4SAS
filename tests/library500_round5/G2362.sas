/* G2362 qupcase_literal_triggers, N=3; source: SAS-Useful-Codes/Macros/HpmixArray.sas:507 */

%let g2362text=%nrstr(a&bad%ghost3);
%let g2362upper=%qupcase(%superq(g2362text));
data g2362o; length text $50; text=symget('g2362upper'); actual=3*(text='A&BAD%GHOST3'); run;
%symdel g2362text g2362upper;

data _null_; if 0 then set g2362o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2362 rows=' rows;
else do; set g2362o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2362';
else put 'ERROR: ROUND5_FAIL=G2362 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2362:; quit;
