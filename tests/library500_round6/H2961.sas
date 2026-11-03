/* H2961 failure_transpose_formatted_id, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

proc format library=work; value h2961f low-high='same'; run;
data h2961a; do k=1 to 2; value=k; output; end; format k h2961f.; run;
proc transpose data=h2961a out=h2961b; id k; var value; run;
proc catalog catalog=work.formats; delete h2961f.format; quit;

proc datasets library=work nolist; delete h2961:; quit;
