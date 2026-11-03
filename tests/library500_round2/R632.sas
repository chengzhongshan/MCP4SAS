/* R632 sql_calculated, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_recurcive_or_dynamic_program_with_hash_to_match_tree_branches.sas:197 */

data r632a; do x=1 to 3; output; end; run;
proc sql; create table r632b as select x,2*x as doubled,calculated doubled+1 as y from r632a;
create table r632o as select sum(y) as actual from r632b; quit;

data _null_; if 0 then set r632o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R632 rows=' rows;
else do; set r632o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND2_PASS=R632';
else put 'ERROR: ROUND2_FAIL=R632 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r632:; quit;
