/* R631 sql_calculated, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_recurcive_or_dynamic_program_with_hash_to_match_tree_branches.sas:197 */

data r631a; do x=1 to 2; output; end; run;
proc sql; create table r631b as select x,2*x as doubled,calculated doubled+1 as y from r631a;
create table r631o as select sum(y) as actual from r631b; quit;

data _null_; if 0 then set r631o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R631 rows=' rows;
else do; set r631o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND2_PASS=R631';
else put 'ERROR: ROUND2_FAIL=R631 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r631:; quit;
