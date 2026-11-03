/* H2969 failure_transpose_formatted_id, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

proc format library=work; value h2969f low-high='same'; run;
data h2969a; do k=1 to 10; value=k; output; end; format k h2969f.; run;
proc transpose data=h2969a out=h2969b; id k; var value; run;
proc catalog catalog=work.formats; delete h2969f.format; quit;

proc datasets library=work nolist; delete h2969:; quit;
