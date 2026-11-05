/* K4499 qsysfunc_masks_punctuation, N=10; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4499text=%qsysfunc(tranwrd(%str(A,B),%str(,),%str(;)));
data k4499o; text=symget('k4499text'); actual=(text='A;B')+10; run; %symdel k4499text;

data _null_; if 0 then set k4499o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4499 rows=' rows;
else do; set k4499o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND10_PASS=K4499';
else put 'ERROR: ROUND10_FAIL=K4499 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4499:; quit;
