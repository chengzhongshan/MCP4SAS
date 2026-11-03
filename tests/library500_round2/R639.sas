/* R639 sql_calculated, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_recurcive_or_dynamic_program_with_hash_to_match_tree_branches.sas:197 */

data r639a; do x=1 to 10; output; end; run;
proc sql; create table r639b as select x,2*x as doubled,calculated doubled+1 as y from r639a;
create table r639o as select sum(y) as actual from r639b; quit;

data _null_; if 0 then set r639o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R639 rows=' rows;
else do; set r639o; if not missing(actual) and abs(actual-(120))<=1e-10*max(1,abs(120)) then put 'ROUND2_PASS=R639';
else put 'ERROR: ROUND2_FAIL=R639 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r639:; quit;
