/* R610 sql_exists, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_binary_function_in_proc_iml_generate_SNP_haplotype.sas:468 */

data r610a; do k=1 to 2*11; output; end; run;
data r610b; do k=1 to 11; output; output; end; run;
proc sql; create table r610o as select sum(k) as actual from r610a a where exists(select * from r610b b where b.k=a.k); quit;

data _null_; if 0 then set r610o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R610 rows=' rows;
else do; set r610o; if not missing(actual) and abs(actual-(66))<=1e-10*max(1,abs(66)) then put 'ROUND2_PASS=R610';
else put 'ERROR: ROUND2_FAIL=R610 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r610:; quit;
