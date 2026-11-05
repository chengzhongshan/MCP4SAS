/* K4331 wide_subset_keeps_only_required_columns, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:781 */

data k4331a; length gene $12; gene='target'; unused=1000000; array exp{*} v1-v2; do j=1 to dim(exp); exp{j}=j; end; run;
data k4331b; set k4331a(keep=gene v: where=(gene='target')); run;
data k4331o; h=open('k4331b','i'); actual=attrn(h,'NVARS'); rc=close(h); run;

data _null_; if 0 then set k4331o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4331 rows=' rows;
else do; set k4331o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND10_PASS=K4331';
else put 'ERROR: ROUND10_FAIL=K4331 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4331:; quit;
