/* H2996 failure_unsorted_by, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data h2996a; do x=7 to 1 by -1; output; end; run;
data h2996b; set h2996a; by x; value=first.x; run;

proc datasets library=work nolist; delete h2996:; quit;
