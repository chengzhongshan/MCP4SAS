/* R635 sql_calculated, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_recurcive_or_dynamic_program_with_hash_to_match_tree_branches.sas:197 */

data r635a; do x=1 to 6; output; end; run;
proc sql; create table r635b as select x,2*x as doubled,calculated doubled+1 as y from r635a;
create table r635o as select sum(y) as actual from r635b; quit;

data _null_; if 0 then set r635o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R635 rows=' rows;
else do; set r635o; if not missing(actual) and abs(actual-(48))<=1e-10*max(1,abs(48)) then put 'ROUND2_PASS=R635';
else put 'ERROR: ROUND2_FAIL=R635 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r635:; quit;
