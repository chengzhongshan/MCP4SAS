/* R606 sql_exists, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_binary_function_in_proc_iml_generate_SNP_haplotype.sas:468 */

data r606a; do k=1 to 2*7; output; end; run;
data r606b; do k=1 to 7; output; output; end; run;
proc sql; create table r606o as select sum(k) as actual from r606a a where exists(select * from r606b b where b.k=a.k); quit;

data _null_; if 0 then set r606o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R606 rows=' rows;
else do; set r606o; if not missing(actual) and abs(actual-(28))<=1e-10*max(1,abs(28)) then put 'ROUND2_PASS=R606';
else put 'ERROR: ROUND2_FAIL=R606 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r606:; quit;
