/* K4333 wide_subset_keeps_only_required_columns, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:781 */

data k4333a; length gene $12; gene='target'; unused=1000000; array exp{*} v1-v4; do j=1 to dim(exp); exp{j}=j; end; run;
data k4333b; set k4333a(keep=gene v: where=(gene='target')); run;
data k4333o; h=open('k4333b','i'); actual=attrn(h,'NVARS'); rc=close(h); run;

data _null_; if 0 then set k4333o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4333 rows=' rows;
else do; set k4333o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND10_PASS=K4333';
else put 'ERROR: ROUND10_FAIL=K4333 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4333:; quit;
