/* K4339 wide_subset_keeps_only_required_columns, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:781 */

data k4339a; length gene $12; gene='target'; unused=1000000; array exp{*} v1-v10; do j=1 to dim(exp); exp{j}=j; end; run;
data k4339b; set k4339a(keep=gene v: where=(gene='target')); run;
data k4339o; h=open('k4339b','i'); actual=attrn(h,'NVARS'); rc=close(h); run;

data _null_; if 0 then set k4339o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4339 rows=' rows;
else do; set k4339o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND10_PASS=K4339';
else put 'ERROR: ROUND10_FAIL=K4339 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4339:; quit;
