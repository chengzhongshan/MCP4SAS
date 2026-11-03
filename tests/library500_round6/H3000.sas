/* H3000 failure_unsorted_by, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data h3000a; do x=11 to 1 by -1; output; end; run;
data h3000b; set h3000a; by x; value=first.x; run;

proc datasets library=work nolist; delete h3000:; quit;
