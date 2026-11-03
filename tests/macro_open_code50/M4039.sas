/* M4039 orphan_mend; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:188 */
%mend;

proc datasets library=work nolist; delete m4039:; quit;
