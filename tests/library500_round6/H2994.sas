/* H2994 failure_unsorted_by, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data h2994a; do x=5 to 1 by -1; output; end; run;
data h2994b; set h2994a; by x; value=first.x; run;

proc datasets library=work nolist; delete h2994:; quit;
