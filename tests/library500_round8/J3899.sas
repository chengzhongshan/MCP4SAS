/* J3899 summary_multilabel_membership, N=10; source: The Power of PROC FORMAT.txt:926 */

proc format; value j3899fmt(multilabel) 1-2='all' 1='one' 2='two'; run;
data j3899a; do j=1 to 10; do grp=1 to 2; output; end; end; format grp j3899fmt.; run;
proc summary data=j3899a nway; class grp / mlf; output out=j3899b; run;
proc sql; create table j3899o as select sum(_freq_) as actual from j3899b; quit;
proc catalog catalog=work.formats; delete j3899fmt.format; quit;

data _null_; if 0 then set j3899o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3899 rows=' rows;
else do; set j3899o; if not missing(actual) and abs(actual-(40))<=1e-9*max(1,abs(40)) then put 'ROUND8_PASS=J3899';
else put 'ERROR: ROUND8_FAIL=J3899 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3899:; quit;
