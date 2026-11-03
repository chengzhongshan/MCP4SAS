/* H2967 failure_transpose_formatted_id, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

proc format library=work; value h2967f low-high='same'; run;
data h2967a; do k=1 to 8; value=k; output; end; format k h2967f.; run;
proc transpose data=h2967a out=h2967b; id k; var value; run;
proc catalog catalog=work.formats; delete h2967f.format; quit;

proc datasets library=work nolist; delete h2967:; quit;
