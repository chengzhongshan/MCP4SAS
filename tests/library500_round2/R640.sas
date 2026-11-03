/* R640 sql_calculated, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_recurcive_or_dynamic_program_with_hash_to_match_tree_branches.sas:197 */

data r640a; do x=1 to 11; output; end; run;
proc sql; create table r640b as select x,2*x as doubled,calculated doubled+1 as y from r640a;
create table r640o as select sum(y) as actual from r640b; quit;

data _null_; if 0 then set r640o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R640 rows=' rows;
else do; set r640o; if not missing(actual) and abs(actual-(143))<=1e-10*max(1,abs(143)) then put 'ROUND2_PASS=R640';
else put 'ERROR: ROUND2_FAIL=R640 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r640:; quit;
