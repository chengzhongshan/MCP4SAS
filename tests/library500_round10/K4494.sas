/* K4494 qsysfunc_masks_punctuation, N=5; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4494text=%qsysfunc(tranwrd(%str(A,B),%str(,),%str(;)));
data k4494o; text=symget('k4494text'); actual=(text='A;B')+5; run; %symdel k4494text;

data _null_; if 0 then set k4494o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4494 rows=' rows;
else do; set k4494o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND10_PASS=K4494';
else put 'ERROR: ROUND10_FAIL=K4494 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4494:; quit;
