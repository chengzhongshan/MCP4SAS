/* H2966 failure_transpose_formatted_id, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

proc format library=work; value h2966f low-high='same'; run;
data h2966a; do k=1 to 7; value=k; output; end; format k h2966f.; run;
proc transpose data=h2966a out=h2966b; id k; var value; run;
proc catalog catalog=work.formats; delete h2966f.format; quit;

proc datasets library=work nolist; delete h2966:; quit;
