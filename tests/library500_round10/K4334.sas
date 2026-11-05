/* K4334 wide_subset_keeps_only_required_columns, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:781 */

data k4334a; length gene $12; gene='target'; unused=1000000; array exp{*} v1-v5; do j=1 to dim(exp); exp{j}=j; end; run;
data k4334b; set k4334a(keep=gene v: where=(gene='target')); run;
data k4334o; h=open('k4334b','i'); actual=attrn(h,'NVARS'); rc=close(h); run;

data _null_; if 0 then set k4334o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4334 rows=' rows;
else do; set k4334o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND10_PASS=K4334';
else put 'ERROR: ROUND10_FAIL=K4334 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4334:; quit;
