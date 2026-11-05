/* K4500 qsysfunc_masks_punctuation, N=11; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4500text=%qsysfunc(tranwrd(%str(A,B),%str(,),%str(;)));
data k4500o; text=symget('k4500text'); actual=(text='A;B')+11; run; %symdel k4500text;

data _null_; if 0 then set k4500o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4500 rows=' rows;
else do; set k4500o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND10_PASS=K4500';
else put 'ERROR: ROUND10_FAIL=K4500 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4500:; quit;
