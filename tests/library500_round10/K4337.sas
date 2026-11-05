/* K4337 wide_subset_keeps_only_required_columns, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:781 */

data k4337a; length gene $12; gene='target'; unused=1000000; array exp{*} v1-v8; do j=1 to dim(exp); exp{j}=j; end; run;
data k4337b; set k4337a(keep=gene v: where=(gene='target')); run;
data k4337o; h=open('k4337b','i'); actual=attrn(h,'NVARS'); rc=close(h); run;

data _null_; if 0 then set k4337o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4337 rows=' rows;
else do; set k4337o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND10_PASS=K4337';
else put 'ERROR: ROUND10_FAIL=K4337 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4337:; quit;
