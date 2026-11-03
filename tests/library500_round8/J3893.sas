/* J3893 summary_multilabel_membership, N=4; source: The Power of PROC FORMAT.txt:926 */

proc format; value j3893fmt(multilabel) 1-2='all' 1='one' 2='two'; run;
data j3893a; do j=1 to 4; do grp=1 to 2; output; end; end; format grp j3893fmt.; run;
proc summary data=j3893a nway; class grp / mlf; output out=j3893b; run;
proc sql; create table j3893o as select sum(_freq_) as actual from j3893b; quit;
proc catalog catalog=work.formats; delete j3893fmt.format; quit;

data _null_; if 0 then set j3893o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3893 rows=' rows;
else do; set j3893o; if not missing(actual) and abs(actual-(16))<=1e-9*max(1,abs(16)) then put 'ROUND8_PASS=J3893';
else put 'ERROR: ROUND8_FAIL=J3893 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3893:; quit;
