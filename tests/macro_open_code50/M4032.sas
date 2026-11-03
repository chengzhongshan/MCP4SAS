/* M4032 orphan_open_else; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1364 */
%else %do; %put orphan; %end;

proc datasets library=work nolist; delete m4032:; quit;
