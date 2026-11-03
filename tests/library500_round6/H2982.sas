/* H2982 failure_calculated_missing, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_recurcive_or_dynamic_program_with_hash_to_match_tree_branches.sas:197 */

data h2982a; x=3; run;
proc sql; create table h2982o as select x,calculated h2982absent as y from h2982a; quit;

proc datasets library=work nolist; delete h2982:; quit;
