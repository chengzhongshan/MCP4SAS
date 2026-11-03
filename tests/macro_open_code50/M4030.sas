/* M4030 invalid_bare_open_do; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:3044 */
%do; %put bare; %end;

proc datasets library=work nolist; delete m4030:; quit;
