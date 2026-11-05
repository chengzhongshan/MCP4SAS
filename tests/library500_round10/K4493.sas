/* K4493 qsysfunc_masks_punctuation, N=4; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4493text=%qsysfunc(tranwrd(%str(A,B),%str(,),%str(;)));
data k4493o; text=symget('k4493text'); actual=(text='A;B')+4; run; %symdel k4493text;

data _null_; if 0 then set k4493o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4493 rows=' rows;
else do; set k4493o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND10_PASS=K4493';
else put 'ERROR: ROUND10_FAIL=K4493 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4493:; quit;
