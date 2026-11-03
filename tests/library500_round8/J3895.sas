/* J3895 summary_multilabel_membership, N=6; source: The Power of PROC FORMAT.txt:926 */

proc format; value j3895fmt(multilabel) 1-2='all' 1='one' 2='two'; run;
data j3895a; do j=1 to 6; do grp=1 to 2; output; end; end; format grp j3895fmt.; run;
proc summary data=j3895a nway; class grp / mlf; output out=j3895b; run;
proc sql; create table j3895o as select sum(_freq_) as actual from j3895b; quit;
proc catalog catalog=work.formats; delete j3895fmt.format; quit;

data _null_; if 0 then set j3895o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3895 rows=' rows;
else do; set j3895o; if not missing(actual) and abs(actual-(24))<=1e-9*max(1,abs(24)) then put 'ROUND8_PASS=J3895';
else put 'ERROR: ROUND8_FAIL=J3895 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3895:; quit;
