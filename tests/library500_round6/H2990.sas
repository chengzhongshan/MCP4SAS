/* H2990 failure_calculated_missing, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_recurcive_or_dynamic_program_with_hash_to_match_tree_branches.sas:197 */

data h2990a; x=11; run;
proc sql; create table h2990o as select x,calculated h2990absent as y from h2990a; quit;

proc datasets library=work nolist; delete h2990:; quit;
