/* M4038 invalid_open_return; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:179 */
%return;

proc datasets library=work nolist; delete m4038:; quit;
