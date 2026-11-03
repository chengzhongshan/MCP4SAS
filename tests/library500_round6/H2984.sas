/* H2984 failure_calculated_missing, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_recurcive_or_dynamic_program_with_hash_to_match_tree_branches.sas:197 */

data h2984a; x=5; run;
proc sql; create table h2984o as select x,calculated h2984absent as y from h2984a; quit;

proc datasets library=work nolist; delete h2984:; quit;
