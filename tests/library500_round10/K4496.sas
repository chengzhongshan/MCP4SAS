/* K4496 qsysfunc_masks_punctuation, N=7; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4496text=%qsysfunc(tranwrd(%str(A,B),%str(,),%str(;)));
data k4496o; text=symget('k4496text'); actual=(text='A;B')+7; run; %symdel k4496text;

data _null_; if 0 then set k4496o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4496 rows=' rows;
else do; set k4496o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND10_PASS=K4496';
else put 'ERROR: ROUND10_FAIL=K4496 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4496:; quit;
