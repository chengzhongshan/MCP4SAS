/* M4035 open_if_requires_do_group; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:400 */
%if 1 %then %put direct;
%end;

proc datasets library=work nolist; delete m4035:; quit;
