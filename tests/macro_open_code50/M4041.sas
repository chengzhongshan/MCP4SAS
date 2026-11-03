/* M4041 eval_decimal_operand; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:481 */
%let m4041v=%eval(1.5+2); %symdel m4041v / nowarn;

proc datasets library=work nolist; delete m4041:; quit;
