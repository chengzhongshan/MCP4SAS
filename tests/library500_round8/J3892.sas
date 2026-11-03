/* J3892 summary_multilabel_membership, N=3; source: The Power of PROC FORMAT.txt:926 */

proc format; value j3892fmt(multilabel) 1-2='all' 1='one' 2='two'; run;
data j3892a; do j=1 to 3; do grp=1 to 2; output; end; end; format grp j3892fmt.; run;
proc summary data=j3892a nway; class grp / mlf; output out=j3892b; run;
proc sql; create table j3892o as select sum(_freq_) as actual from j3892b; quit;
proc catalog catalog=work.formats; delete j3892fmt.format; quit;

data _null_; if 0 then set j3892o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3892 rows=' rows;
else do; set j3892o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND8_PASS=J3892';
else put 'ERROR: ROUND8_FAIL=J3892 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3892:; quit;
