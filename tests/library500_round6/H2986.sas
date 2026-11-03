/* H2986 failure_calculated_missing, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_recurcive_or_dynamic_program_with_hash_to_match_tree_branches.sas:197 */

data h2986a; x=7; run;
proc sql; create table h2986o as select x,calculated h2986absent as y from h2986a; quit;

proc datasets library=work nolist; delete h2986:; quit;
