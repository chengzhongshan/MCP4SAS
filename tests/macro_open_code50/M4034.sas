/* M4034 nested_open_if; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:400 */
%if 1 %then %do; %if 1 %then %do; %put nested; %end; %end;

proc datasets library=work nolist; delete m4034:; quit;
