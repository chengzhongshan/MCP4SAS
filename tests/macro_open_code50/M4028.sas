/* M4028 invalid_open_while_do; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:503 */
%do %while(0); %put never; %end;

proc datasets library=work nolist; delete m4028:; quit;
