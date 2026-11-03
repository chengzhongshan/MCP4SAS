/* M4037 invalid_open_goto; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:3038 */
%goto m4037label;

proc datasets library=work nolist; delete m4037:; quit;
