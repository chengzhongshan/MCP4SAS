/* H2963 failure_transpose_formatted_id, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

proc format library=work; value h2963f low-high='same'; run;
data h2963a; do k=1 to 4; value=k; output; end; format k h2963f.; run;
proc transpose data=h2963a out=h2963b; id k; var value; run;
proc catalog catalog=work.formats; delete h2963f.format; quit;

proc datasets library=work nolist; delete h2963:; quit;
