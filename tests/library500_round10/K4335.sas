/* K4335 wide_subset_keeps_only_required_columns, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:781 */

data k4335a; length gene $12; gene='target'; unused=1000000; array exp{*} v1-v6; do j=1 to dim(exp); exp{j}=j; end; run;
data k4335b; set k4335a(keep=gene v: where=(gene='target')); run;
data k4335o; h=open('k4335b','i'); actual=attrn(h,'NVARS'); rc=close(h); run;

data _null_; if 0 then set k4335o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4335 rows=' rows;
else do; set k4335o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND10_PASS=K4335';
else put 'ERROR: ROUND10_FAIL=K4335 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4335:; quit;
