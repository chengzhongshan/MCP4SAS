/* H2983 failure_calculated_missing, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_recurcive_or_dynamic_program_with_hash_to_match_tree_branches.sas:197 */

data h2983a; x=4; run;
proc sql; create table h2983o as select x,calculated h2983absent as y from h2983a; quit;

proc datasets library=work nolist; delete h2983:; quit;
