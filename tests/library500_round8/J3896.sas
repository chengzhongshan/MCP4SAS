/* J3896 summary_multilabel_membership, N=7; source: The Power of PROC FORMAT.txt:926 */

proc format; value j3896fmt(multilabel) 1-2='all' 1='one' 2='two'; run;
data j3896a; do j=1 to 7; do grp=1 to 2; output; end; end; format grp j3896fmt.; run;
proc summary data=j3896a nway; class grp / mlf; output out=j3896b; run;
proc sql; create table j3896o as select sum(_freq_) as actual from j3896b; quit;
proc catalog catalog=work.formats; delete j3896fmt.format; quit;

data _null_; if 0 then set j3896o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3896 rows=' rows;
else do; set j3896o; if not missing(actual) and abs(actual-(28))<=1e-9*max(1,abs(28)) then put 'ROUND8_PASS=J3896';
else put 'ERROR: ROUND8_FAIL=J3896 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3896:; quit;
