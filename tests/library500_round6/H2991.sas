/* H2991 failure_unsorted_by, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data h2991a; do x=2 to 1 by -1; output; end; run;
data h2991b; set h2991a; by x; value=first.x; run;

proc datasets library=work nolist; delete h2991:; quit;
