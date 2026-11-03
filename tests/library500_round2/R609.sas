/* R609 sql_exists, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_binary_function_in_proc_iml_generate_SNP_haplotype.sas:468 */

data r609a; do k=1 to 2*10; output; end; run;
data r609b; do k=1 to 10; output; output; end; run;
proc sql; create table r609o as select sum(k) as actual from r609a a where exists(select * from r609b b where b.k=a.k); quit;

data _null_; if 0 then set r609o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R609 rows=' rows;
else do; set r609o; if not missing(actual) and abs(actual-(55))<=1e-10*max(1,abs(55)) then put 'ROUND2_PASS=R609';
else put 'ERROR: ROUND2_FAIL=R609 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r609:; quit;
