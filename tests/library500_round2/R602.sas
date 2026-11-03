/* R602 sql_exists, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_binary_function_in_proc_iml_generate_SNP_haplotype.sas:468 */

data r602a; do k=1 to 2*3; output; end; run;
data r602b; do k=1 to 3; output; output; end; run;
proc sql; create table r602o as select sum(k) as actual from r602a a where exists(select * from r602b b where b.k=a.k); quit;

data _null_; if 0 then set r602o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R602 rows=' rows;
else do; set r602o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND2_PASS=R602';
else put 'ERROR: ROUND2_FAIL=R602 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r602:; quit;
