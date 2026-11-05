/* K4491 qsysfunc_masks_punctuation, N=2; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4491text=%qsysfunc(tranwrd(%str(A,B),%str(,),%str(;)));
data k4491o; text=symget('k4491text'); actual=(text='A;B')+2; run; %symdel k4491text;

data _null_; if 0 then set k4491o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4491 rows=' rows;
else do; set k4491o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND10_PASS=K4491';
else put 'ERROR: ROUND10_FAIL=K4491 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4491:; quit;
