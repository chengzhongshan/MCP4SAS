/* J3894 summary_multilabel_membership, N=5; source: The Power of PROC FORMAT.txt:926 */

proc format; value j3894fmt(multilabel) 1-2='all' 1='one' 2='two'; run;
data j3894a; do j=1 to 5; do grp=1 to 2; output; end; end; format grp j3894fmt.; run;
proc summary data=j3894a nway; class grp / mlf; output out=j3894b; run;
proc sql; create table j3894o as select sum(_freq_) as actual from j3894b; quit;
proc catalog catalog=work.formats; delete j3894fmt.format; quit;

data _null_; if 0 then set j3894o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3894 rows=' rows;
else do; set j3894o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND8_PASS=J3894';
else put 'ERROR: ROUND8_FAIL=J3894 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3894:; quit;
