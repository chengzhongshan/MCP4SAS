/* M4036 missing_let_semicolon_recursion; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:104 */
%let m4036v=1
%put &m4036v;
; %symdel m4036v / nowarn;

proc datasets library=work nolist; delete m4036:; quit;
