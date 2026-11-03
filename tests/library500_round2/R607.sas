/* R607 sql_exists, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_binary_function_in_proc_iml_generate_SNP_haplotype.sas:468 */

data r607a; do k=1 to 2*8; output; end; run;
data r607b; do k=1 to 8; output; output; end; run;
proc sql; create table r607o as select sum(k) as actual from r607a a where exists(select * from r607b b where b.k=a.k); quit;

data _null_; if 0 then set r607o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R607 rows=' rows;
else do; set r607o; if not missing(actual) and abs(actual-(36))<=1e-10*max(1,abs(36)) then put 'ROUND2_PASS=R607';
else put 'ERROR: ROUND2_FAIL=R607 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r607:; quit;
