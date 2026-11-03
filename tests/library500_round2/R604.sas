/* R604 sql_exists, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_binary_function_in_proc_iml_generate_SNP_haplotype.sas:468 */

data r604a; do k=1 to 2*5; output; end; run;
data r604b; do k=1 to 5; output; output; end; run;
proc sql; create table r604o as select sum(k) as actual from r604a a where exists(select * from r604b b where b.k=a.k); quit;

data _null_; if 0 then set r604o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R604 rows=' rows;
else do; set r604o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND2_PASS=R604';
else put 'ERROR: ROUND2_FAIL=R604 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r604:; quit;
