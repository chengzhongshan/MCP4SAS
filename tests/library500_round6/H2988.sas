/* H2988 failure_calculated_missing, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/use_recurcive_or_dynamic_program_with_hash_to_match_tree_branches.sas:197 */

data h2988a; x=9; run;
proc sql; create table h2988o as select x,calculated h2988absent as y from h2988a; quit;

proc datasets library=work nolist; delete h2988:; quit;
