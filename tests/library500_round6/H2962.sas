/* H2962 failure_transpose_formatted_id, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

proc format library=work; value h2962f low-high='same'; run;
data h2962a; do k=1 to 3; value=k; output; end; format k h2962f.; run;
proc transpose data=h2962a out=h2962b; id k; var value; run;
proc catalog catalog=work.formats; delete h2962f.format; quit;

proc datasets library=work nolist; delete h2962:; quit;
