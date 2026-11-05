/* K4340 wide_subset_keeps_only_required_columns, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:781 */

data k4340a; length gene $12; gene='target'; unused=1000000; array exp{*} v1-v11; do j=1 to dim(exp); exp{j}=j; end; run;
data k4340b; set k4340a(keep=gene v: where=(gene='target')); run;
data k4340o; h=open('k4340b','i'); actual=attrn(h,'NVARS'); rc=close(h); run;

data _null_; if 0 then set k4340o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4340 rows=' rows;
else do; set k4340o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND10_PASS=K4340';
else put 'ERROR: ROUND10_FAIL=K4340 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4340:; quit;
