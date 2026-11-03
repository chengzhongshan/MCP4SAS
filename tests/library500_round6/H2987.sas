/* H2987 failure_calculated_missing, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_recurcive_or_dynamic_program_with_hash_to_match_tree_branches.sas:197 */

data h2987a; x=8; run;
proc sql; create table h2987o as select x,calculated h2987absent as y from h2987a; quit;

proc datasets library=work nolist; delete h2987:; quit;
