/* R605 sql_exists, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_binary_function_in_proc_iml_generate_SNP_haplotype.sas:468 */

data r605a; do k=1 to 2*6; output; end; run;
data r605b; do k=1 to 6; output; output; end; run;
proc sql; create table r605o as select sum(k) as actual from r605a a where exists(select * from r605b b where b.k=a.k); quit;

data _null_; if 0 then set r605o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R605 rows=' rows;
else do; set r605o; if not missing(actual) and abs(actual-(21))<=1e-10*max(1,abs(21)) then put 'ROUND2_PASS=R605';
else put 'ERROR: ROUND2_FAIL=R605 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r605:; quit;
