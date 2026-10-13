/* Public GTEx significant eQTLs for APOBEC3A.
   Pin the dataset and matching gene annotation instead of using API defaults.
   v8 / GENCODE v26: ENSG00000128383.12
   v10 / GENCODE v39: ENSG00000128383.13
   https://gtexportal.org/api/v2/redoc
*/
%macro query_eqtl;
%local total pages;
filename response temp;
proc http
    url="https://gtexportal.org/api/v2/association/singleTissueEqtl?gencodeId=ENSG00000128383.12%str(&)datasetId=gtex_v8%str(&)itemsPerPage=100000"
    method="GET" out=response;
run;
%if not %symexist(SYS_PROCHTTP_STATUS_CODE) %then %do;
    %put ERROR: GTEx request failed before an HTTP status was available.;
    %goto cleanup;
%end;
%if %superq(SYS_PROCHTTP_STATUS_CODE) ne 200 %then %do;
    %put ERROR: GTEx HTTP status=&SYS_PROCHTTP_STATUS_CODE.;
    %goto cleanup;
%end;
libname eqtljson json fileref=response;
%if not %sysfunc(exist(eqtljson.paging_info)) %then %do;
    %put ERROR: Missing GTEx paging metadata.;
    %goto clear_json;
%end;
data _null_;
    set eqtljson.paging_info;
    call symputx('total',totalNumberOfItems,'L');
    call symputx('pages',numberOfPages,'L');
run;
%if &total=0 or &pages>1 %then %do;
    %put ERROR: GTEx returned empty or incomplete results total=&total pages=&pages.;
    %goto clear_json;
%end;
%if not %sysfunc(exist(eqtljson.data)) %then %do;
    %put ERROR: Missing GTEx data table.;
    %goto clear_json;
%end;
data gene_eqtls;
    set eqtljson.data;
    drop ordinal:;
run;
title "APOBEC3A significant eQTLs in GTEx v8";
proc sql;
    select count(*) as eQTL_records,
           count(distinct tissueSiteDetailId) as tissues from gene_eqtls;
quit;
proc print data=gene_eqtls(obs=10); run;
title;
%clear_json:
libname eqtljson clear;
%cleanup:
filename response clear;
%mend;
%query_eqtl;
