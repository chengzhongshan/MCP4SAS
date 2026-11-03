/* H2989 failure_calculated_missing, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_recurcive_or_dynamic_program_with_hash_to_match_tree_branches.sas:197 */

data h2989a; x=10; run;
proc sql; create table h2989o as select x,calculated h2989absent as y from h2989a; quit;

proc datasets library=work nolist; delete h2989:; quit;
