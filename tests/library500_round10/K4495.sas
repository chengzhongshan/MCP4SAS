/* K4495 qsysfunc_masks_punctuation, N=6; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4495text=%qsysfunc(tranwrd(%str(A,B),%str(,),%str(;)));
data k4495o; text=symget('k4495text'); actual=(text='A;B')+6; run; %symdel k4495text;

data _null_; if 0 then set k4495o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4495 rows=' rows;
else do; set k4495o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND10_PASS=K4495';
else put 'ERROR: ROUND10_FAIL=K4495 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4495:; quit;
