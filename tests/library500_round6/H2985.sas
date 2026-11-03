/* H2985 failure_calculated_missing, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_recurcive_or_dynamic_program_with_hash_to_match_tree_branches.sas:197 */

data h2985a; x=6; run;
proc sql; create table h2985o as select x,calculated h2985absent as y from h2985a; quit;

proc datasets library=work nolist; delete h2985:; quit;
