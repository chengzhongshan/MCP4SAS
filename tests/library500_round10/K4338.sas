/* K4338 wide_subset_keeps_only_required_columns, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:781 */

data k4338a; length gene $12; gene='target'; unused=1000000; array exp{*} v1-v9; do j=1 to dim(exp); exp{j}=j; end; run;
data k4338b; set k4338a(keep=gene v: where=(gene='target')); run;
data k4338o; h=open('k4338b','i'); actual=attrn(h,'NVARS'); rc=close(h); run;

data _null_; if 0 then set k4338o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4338 rows=' rows;
else do; set k4338o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND10_PASS=K4338';
else put 'ERROR: ROUND10_FAIL=K4338 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4338:; quit;
