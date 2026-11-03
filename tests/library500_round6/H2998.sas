/* H2998 failure_unsorted_by, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data h2998a; do x=9 to 1 by -1; output; end; run;
data h2998b; set h2998a; by x; value=first.x; run;

proc datasets library=work nolist; delete h2998:; quit;
