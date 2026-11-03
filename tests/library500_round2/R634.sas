/* R634 sql_calculated, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_recurcive_or_dynamic_program_with_hash_to_match_tree_branches.sas:197 */

data r634a; do x=1 to 5; output; end; run;
proc sql; create table r634b as select x,2*x as doubled,calculated doubled+1 as y from r634a;
create table r634o as select sum(y) as actual from r634b; quit;

data _null_; if 0 then set r634o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R634 rows=' rows;
else do; set r634o; if not missing(actual) and abs(actual-(35))<=1e-10*max(1,abs(35)) then put 'ROUND2_PASS=R634';
else put 'ERROR: ROUND2_FAIL=R634 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r634:; quit;
