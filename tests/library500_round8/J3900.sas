/* J3900 summary_multilabel_membership, N=11; source: The Power of PROC FORMAT.txt:926 */

proc format; value j3900fmt(multilabel) 1-2='all' 1='one' 2='two'; run;
data j3900a; do j=1 to 11; do grp=1 to 2; output; end; end; format grp j3900fmt.; run;
proc summary data=j3900a nway; class grp / mlf; output out=j3900b; run;
proc sql; create table j3900o as select sum(_freq_) as actual from j3900b; quit;
proc catalog catalog=work.formats; delete j3900fmt.format; quit;

data _null_; if 0 then set j3900o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3900 rows=' rows;
else do; set j3900o; if not missing(actual) and abs(actual-(44))<=1e-9*max(1,abs(44)) then put 'ROUND8_PASS=J3900';
else put 'ERROR: ROUND8_FAIL=J3900 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3900:; quit;
