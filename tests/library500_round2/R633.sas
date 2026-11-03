/* R633 sql_calculated, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_recurcive_or_dynamic_program_with_hash_to_match_tree_branches.sas:197 */

data r633a; do x=1 to 4; output; end; run;
proc sql; create table r633b as select x,2*x as doubled,calculated doubled+1 as y from r633a;
create table r633o as select sum(y) as actual from r633b; quit;

data _null_; if 0 then set r633o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R633 rows=' rows;
else do; set r633o; if not missing(actual) and abs(actual-(24))<=1e-10*max(1,abs(24)) then put 'ROUND2_PASS=R633';
else put 'ERROR: ROUND2_FAIL=R633 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r633:; quit;
