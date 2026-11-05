/* K4336 wide_subset_keeps_only_required_columns, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:781 */

data k4336a; length gene $12; gene='target'; unused=1000000; array exp{*} v1-v7; do j=1 to dim(exp); exp{j}=j; end; run;
data k4336b; set k4336a(keep=gene v: where=(gene='target')); run;
data k4336o; h=open('k4336b','i'); actual=attrn(h,'NVARS'); rc=close(h); run;

data _null_; if 0 then set k4336o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4336 rows=' rows;
else do; set k4336o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND10_PASS=K4336';
else put 'ERROR: ROUND10_FAIL=K4336 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4336:; quit;
