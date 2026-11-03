/* J3891 summary_multilabel_membership, N=2; source: The Power of PROC FORMAT.txt:926 */

proc format; value j3891fmt(multilabel) 1-2='all' 1='one' 2='two'; run;
data j3891a; do j=1 to 2; do grp=1 to 2; output; end; end; format grp j3891fmt.; run;
proc summary data=j3891a nway; class grp / mlf; output out=j3891b; run;
proc sql; create table j3891o as select sum(_freq_) as actual from j3891b; quit;
proc catalog catalog=work.formats; delete j3891fmt.format; quit;

data _null_; if 0 then set j3891o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3891 rows=' rows;
else do; set j3891o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND8_PASS=J3891';
else put 'ERROR: ROUND8_FAIL=J3891 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3891:; quit;
