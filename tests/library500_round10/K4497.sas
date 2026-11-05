/* K4497 qsysfunc_masks_punctuation, N=8; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4497text=%qsysfunc(tranwrd(%str(A,B),%str(,),%str(;)));
data k4497o; text=symget('k4497text'); actual=(text='A;B')+8; run; %symdel k4497text;

data _null_; if 0 then set k4497o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4497 rows=' rows;
else do; set k4497o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND10_PASS=K4497';
else put 'ERROR: ROUND10_FAIL=K4497 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4497:; quit;
