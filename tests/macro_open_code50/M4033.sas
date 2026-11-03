/* M4033 orphan_open_then; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:400 */
%then %do; %put orphan; %end;

proc datasets library=work nolist; delete m4033:; quit;
