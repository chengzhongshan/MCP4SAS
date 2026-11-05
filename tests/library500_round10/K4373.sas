/* K4373 summary_classdata_empty_group, N=4; source: PROC TABULATE by Example.txt:739 */

data k4373a; do j=1 to 4; grp=1; x=j; output; end; run;
data k4373classes; grp=1; output; grp=2; output; run;
proc summary data=k4373a classdata=k4373classes nway completetypes; class grp; var x; output out=k4373b sum=total; run;
data k4373o; set k4373b; if grp=2; actual=_freq_; run;

data _null_; if 0 then set k4373o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4373 rows=' rows;
else do; set k4373o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND10_PASS=K4373';
else put 'ERROR: ROUND10_FAIL=K4373 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4373:; quit;
