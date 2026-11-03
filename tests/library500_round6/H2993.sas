/* H2993 failure_unsorted_by, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data h2993a; do x=4 to 1 by -1; output; end; run;
data h2993b; set h2993a; by x; value=first.x; run;

proc datasets library=work nolist; delete h2993:; quit;
