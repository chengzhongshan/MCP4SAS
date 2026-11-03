/* H2970 failure_transpose_formatted_id, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

proc format library=work; value h2970f low-high='same'; run;
data h2970a; do k=1 to 11; value=k; output; end; format k h2970f.; run;
proc transpose data=h2970a out=h2970b; id k; var value; run;
proc catalog catalog=work.formats; delete h2970f.format; quit;

proc datasets library=work nolist; delete h2970:; quit;
