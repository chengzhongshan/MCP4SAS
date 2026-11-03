/* R608 sql_exists, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_binary_function_in_proc_iml_generate_SNP_haplotype.sas:468 */

data r608a; do k=1 to 2*9; output; end; run;
data r608b; do k=1 to 9; output; output; end; run;
proc sql; create table r608o as select sum(k) as actual from r608a a where exists(select * from r608b b where b.k=a.k); quit;

data _null_; if 0 then set r608o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R608 rows=' rows;
else do; set r608o; if not missing(actual) and abs(actual-(45))<=1e-10*max(1,abs(45)) then put 'ROUND2_PASS=R608';
else put 'ERROR: ROUND2_FAIL=R608 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r608:; quit;
