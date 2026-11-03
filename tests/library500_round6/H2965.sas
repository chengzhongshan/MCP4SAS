/* H2965 failure_transpose_formatted_id, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

proc format library=work; value h2965f low-high='same'; run;
data h2965a; do k=1 to 6; value=k; output; end; format k h2965f.; run;
proc transpose data=h2965a out=h2965b; id k; var value; run;
proc catalog catalog=work.formats; delete h2965f.format; quit;

proc datasets library=work nolist; delete h2965:; quit;
