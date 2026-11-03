/* H2964 failure_transpose_formatted_id, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

proc format library=work; value h2964f low-high='same'; run;
data h2964a; do k=1 to 5; value=k; output; end; format k h2964f.; run;
proc transpose data=h2964a out=h2964b; id k; var value; run;
proc catalog catalog=work.formats; delete h2964f.format; quit;

proc datasets library=work nolist; delete h2964:; quit;
