/* M4042 sysfunc_unknown_function; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */
%let m4042v=%sysfunc(m4042unknown()); %symdel m4042v / nowarn;

proc datasets library=work nolist; delete m4042:; quit;
