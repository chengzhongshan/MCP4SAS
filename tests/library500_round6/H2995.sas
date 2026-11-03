/* H2995 failure_unsorted_by, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data h2995a; do x=6 to 1 by -1; output; end; run;
data h2995b; set h2995a; by x; value=first.x; run;

proc datasets library=work nolist; delete h2995:; quit;
