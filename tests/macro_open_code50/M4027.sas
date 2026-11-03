/* M4027 invalid_open_indexed_do; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:441 */
%do m4027i=1 %to 2; %put &m4027i; %end;

proc datasets library=work nolist; delete m4027:; quit;
