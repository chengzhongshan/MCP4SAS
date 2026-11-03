/* J3897 summary_multilabel_membership, N=8; source: The Power of PROC FORMAT.txt:926 */

proc format; value j3897fmt(multilabel) 1-2='all' 1='one' 2='two'; run;
data j3897a; do j=1 to 8; do grp=1 to 2; output; end; end; format grp j3897fmt.; run;
proc summary data=j3897a nway; class grp / mlf; output out=j3897b; run;
proc sql; create table j3897o as select sum(_freq_) as actual from j3897b; quit;
proc catalog catalog=work.formats; delete j3897fmt.format; quit;

data _null_; if 0 then set j3897o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3897 rows=' rows;
else do; set j3897o; if not missing(actual) and abs(actual-(32))<=1e-9*max(1,abs(32)) then put 'ROUND8_PASS=J3897';
else put 'ERROR: ROUND8_FAIL=J3897 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3897:; quit;
