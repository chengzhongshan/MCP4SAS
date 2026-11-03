/* H2997 failure_unsorted_by, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data h2997a; do x=8 to 1 by -1; output; end; run;
data h2997b; set h2997a; by x; value=first.x; run;

proc datasets library=work nolist; delete h2997:; quit;
