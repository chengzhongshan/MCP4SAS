/* R603 sql_exists, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_binary_function_in_proc_iml_generate_SNP_haplotype.sas:468 */

data r603a; do k=1 to 2*4; output; end; run;
data r603b; do k=1 to 4; output; output; end; run;
proc sql; create table r603o as select sum(k) as actual from r603a a where exists(select * from r603b b where b.k=a.k); quit;

data _null_; if 0 then set r603o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R603 rows=' rows;
else do; set r603o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND2_PASS=R603';
else put 'ERROR: ROUND2_FAIL=R603 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r603:; quit;
