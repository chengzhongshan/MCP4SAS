/* H2992 failure_unsorted_by, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data h2992a; do x=3 to 1 by -1; output; end; run;
data h2992b; set h2992a; by x; value=first.x; run;

proc datasets library=work nolist; delete h2992:; quit;
