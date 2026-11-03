/* R638 sql_calculated, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_recurcive_or_dynamic_program_with_hash_to_match_tree_branches.sas:197 */

data r638a; do x=1 to 9; output; end; run;
proc sql; create table r638b as select x,2*x as doubled,calculated doubled+1 as y from r638a;
create table r638o as select sum(y) as actual from r638b; quit;

data _null_; if 0 then set r638o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R638 rows=' rows;
else do; set r638o; if not missing(actual) and abs(actual-(99))<=1e-10*max(1,abs(99)) then put 'ROUND2_PASS=R638';
else put 'ERROR: ROUND2_FAIL=R638 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r638:; quit;
