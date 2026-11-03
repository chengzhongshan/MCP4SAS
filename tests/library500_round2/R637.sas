/* R637 sql_calculated, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_recurcive_or_dynamic_program_with_hash_to_match_tree_branches.sas:197 */

data r637a; do x=1 to 8; output; end; run;
proc sql; create table r637b as select x,2*x as doubled,calculated doubled+1 as y from r637a;
create table r637o as select sum(y) as actual from r637b; quit;

data _null_; if 0 then set r637o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R637 rows=' rows;
else do; set r637o; if not missing(actual) and abs(actual-(80))<=1e-10*max(1,abs(80)) then put 'ROUND2_PASS=R637';
else put 'ERROR: ROUND2_FAIL=R637 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r637:; quit;
