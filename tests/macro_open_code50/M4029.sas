/* M4029 invalid_open_until_do; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:480 */
%do %until(1); %put once; %end;

proc datasets library=work nolist; delete m4029:; quit;
