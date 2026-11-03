/* M4040 eval_division_zero; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:481 */
%let m4040v=%eval(7/0); %symdel m4040v / nowarn;

proc datasets library=work nolist; delete m4040:; quit;
