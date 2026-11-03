/* J3898 summary_multilabel_membership, N=9; source: The Power of PROC FORMAT.txt:926 */

proc format; value j3898fmt(multilabel) 1-2='all' 1='one' 2='two'; run;
data j3898a; do j=1 to 9; do grp=1 to 2; output; end; end; format grp j3898fmt.; run;
proc summary data=j3898a nway; class grp / mlf; output out=j3898b; run;
proc sql; create table j3898o as select sum(_freq_) as actual from j3898b; quit;
proc catalog catalog=work.formats; delete j3898fmt.format; quit;

data _null_; if 0 then set j3898o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3898 rows=' rows;
else do; set j3898o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND8_PASS=J3898';
else put 'ERROR: ROUND8_FAIL=J3898 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3898:; quit;
