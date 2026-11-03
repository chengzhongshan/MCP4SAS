/* M4045 empty_if_expression_in_macro; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:400 */
%macro m4045m; %if %then %put empty; %mend; %m4045m; %sysmacdelete m4045m / nowarn;

proc datasets library=work nolist; delete m4045:; quit;
