/* M4043 macro_duplicate_parameters; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:179 */
%macro m4043m(a,a); %put duplicate; %mend; %sysmacdelete m4043m / nowarn;

proc datasets library=work nolist; delete m4043:; quit;
