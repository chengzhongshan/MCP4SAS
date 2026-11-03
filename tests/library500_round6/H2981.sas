/* H2981 failure_calculated_missing, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_recurcive_or_dynamic_program_with_hash_to_match_tree_branches.sas:197 */

data h2981a; x=2; run;
proc sql; create table h2981o as select x,calculated h2981absent as y from h2981a; quit;

proc datasets library=work nolist; delete h2981:; quit;
