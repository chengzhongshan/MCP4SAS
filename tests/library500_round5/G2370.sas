/* G2370 qupcase_literal_triggers, N=11; source: SAS-Useful-Codes/Macros/HpmixArray.sas:507 */

%let g2370text=%nrstr(a&bad%ghost11);
%let g2370upper=%qupcase(%superq(g2370text));
data g2370o; length text $50; text=symget('g2370upper'); actual=11*(text='A&BAD%GHOST11'); run;
%symdel g2370text g2370upper;

data _null_; if 0 then set g2370o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2370 rows=' rows;
else do; set g2370o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND5_PASS=G2370';
else put 'ERROR: ROUND5_FAIL=G2370 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2370:; quit;
