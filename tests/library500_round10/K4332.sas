/* K4332 wide_subset_keeps_only_required_columns, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:781 */

data k4332a; length gene $12; gene='target'; unused=1000000; array exp{*} v1-v3; do j=1 to dim(exp); exp{j}=j; end; run;
data k4332b; set k4332a(keep=gene v: where=(gene='target')); run;
data k4332o; h=open('k4332b','i'); actual=attrn(h,'NVARS'); rc=close(h); run;

data _null_; if 0 then set k4332o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4332 rows=' rows;
else do; set k4332o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND10_PASS=K4332';
else put 'ERROR: ROUND10_FAIL=K4332 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4332:; quit;
