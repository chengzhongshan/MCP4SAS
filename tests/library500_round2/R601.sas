/* R601 sql_exists, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_binary_function_in_proc_iml_generate_SNP_haplotype.sas:468 */

data r601a; do k=1 to 2*2; output; end; run;
data r601b; do k=1 to 2; output; output; end; run;
proc sql; create table r601o as select sum(k) as actual from r601a a where exists(select * from r601b b where b.k=a.k); quit;

data _null_; if 0 then set r601o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R601 rows=' rows;
else do; set r601o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND2_PASS=R601';
else put 'ERROR: ROUND2_FAIL=R601 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r601:; quit;
