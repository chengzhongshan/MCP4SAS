/* H2999 failure_unsorted_by, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:35 */

data h2999a; do x=10 to 1 by -1; output; end; run;
data h2999b; set h2999a; by x; value=first.x; run;

proc datasets library=work nolist; delete h2999:; quit;
