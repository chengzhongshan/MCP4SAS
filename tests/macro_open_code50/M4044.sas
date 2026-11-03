/* M4044 positional_after_keyword_argument; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:179 */
%macro m4044m(a=,b=); %put &a &b; %mend; %m4044m(a=1,2); %sysmacdelete m4044m;

proc datasets library=work nolist; delete m4044:; quit;
