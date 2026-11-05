/* K4492 qsysfunc_masks_punctuation, N=3; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4492text=%qsysfunc(tranwrd(%str(A,B),%str(,),%str(;)));
data k4492o; text=symget('k4492text'); actual=(text='A;B')+3; run; %symdel k4492text;

data _null_; if 0 then set k4492o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4492 rows=' rows;
else do; set k4492o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND10_PASS=K4492';
else put 'ERROR: ROUND10_FAIL=K4492 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4492:; quit;
