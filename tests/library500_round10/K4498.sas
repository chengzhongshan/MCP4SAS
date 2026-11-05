/* K4498 qsysfunc_masks_punctuation, N=9; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4498text=%qsysfunc(tranwrd(%str(A,B),%str(,),%str(;)));
data k4498o; text=symget('k4498text'); actual=(text='A;B')+9; run; %symdel k4498text;

data _null_; if 0 then set k4498o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4498 rows=' rows;
else do; set k4498o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND10_PASS=K4498';
else put 'ERROR: ROUND10_FAIL=K4498 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4498:; quit;
