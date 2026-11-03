/* H2968 failure_transpose_formatted_id, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

proc format library=work; value h2968f low-high='same'; run;
data h2968a; do k=1 to 9; value=k; output; end; format k h2968f.; run;
proc transpose data=h2968a out=h2968b; id k; var value; run;
proc catalog catalog=work.formats; delete h2968f.format; quit;

proc datasets library=work nolist; delete h2968:; quit;
