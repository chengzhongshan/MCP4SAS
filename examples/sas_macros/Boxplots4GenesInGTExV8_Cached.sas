/* Cache-only alternative: no HTTP requests, full-matrix import or cache writes.
   PreviousDsd must be long data: rownames, exp, cluster, and sex (or Tissue).
   exp is already transformed exactly as in the original generated tgt table. */
%macro Boxplots4GenesInGTExV8_Cached(
 genes=MAP3K19 R3HDM1, dsdout=exp, bysex=1, UseGeneratedDsd=1,
 PreviousDsd=tgt, Lib4PreviousDsd=GTEx, WhereFilters4Boxplot=%str(),
 boxplot_width=1200, boxplot_height=1000, replace=0);
 %local _source _handle _rc _group _wanted _tag _stage _count _bad _idx _gene;
 %if %superq(UseGeneratedDsd) ne 1 %then %do;
   %put ERROR: GTEX_CACHE_ONLY: Set UseGeneratedDsd=1 with a prepared long dataset. Full expression-matrix downloads are disabled.;
   %return;
 %end;
 %if %length(%superq(genes))=0 or %length(%superq(PreviousDsd))=0 %then %do;
   %put ERROR: GTEX_CACHE_ONLY: genes and PreviousDsd must be specified.; %return;
 %end;
 %let _source=&Lib4PreviousDsd..&PreviousDsd;
 %if not %sysfunc(exist(&_source)) %then %do;
   %put ERROR: GTEX_CACHE_ONLY: Prepared long dataset &_source does not exist. No download was attempted.; %return;
 %end;
 %if %superq(bysex)=1 %then %let _group=sex;
 %else %let _group=Tissue;
 %let _handle=%sysfunc(open(&_source,i));
 %if &_handle=0 %then %do;
   %put ERROR: GTEX_CACHE_ONLY: Cannot open &_source.; %return;
 %end;
 %let _bad=0;
 %do _idx=1 %to 4;
   %let _gene=%scan(rownames exp cluster &_group,&_idx);
   %if %sysfunc(varnum(&_handle,&_gene))=0 %then %let _bad=1;
 %end;
 %if %sysfunc(varnum(&_handle,exp))>0 %then %do;
   %if %sysfunc(vartype(&_handle,%sysfunc(varnum(&_handle,exp)))) ne N %then %let _bad=1;
 %end;
 %let _rc=%sysfunc(close(&_handle));
 %if &_bad %then %do;
   %put ERROR: GTEX_CACHE_ONLY: Required columns are rownames numeric exp cluster &_group..; %return;
 %end;
 %if %sysfunc(exist(&dsdout)) and %superq(replace) ne 1 %then %do;
   %put ERROR: GTEX_CACHE_ONLY: Output &dsdout exists. Choose another output or specify replace=1.; %return;
 %end;
 %if %upcase(%qscan(%superq(dsdout),-1,%str(.)))=%upcase(%qscan(%superq(PreviousDsd),-1,%str(.))) %then %do;
   %put ERROR: GTEX_CACHE_ONLY: Output must differ from the source cache.; %return;
 %end;
 %let _wanted=%superq(genes);
 %let _tag=_b4g%substr(%sysfunc(compress(%sysfunc(uuidgen()),%str(-))),1,20);
 %let _stage=work.&_tag;
 data &_stage;
   set &_source;
   %if %length(%superq(WhereFilters4Boxplot)) %then %do;
     where %unquote(&WhereFilters4Boxplot);
   %end;
   /* Strip the gene token; FINDW's T modifier also trims a space-only delimiter. */
   if findw("%superq(_wanted)",strip(scan(rownames,-1,'|')),' ','i')>0;
   rownames=scan(rownames,-1,'|');
 run;
 %let _bad=0;
 %do _idx=1 %to %sysfunc(countw(%superq(_wanted),%str( )));
   %let _gene=%qscan(%superq(_wanted),&_idx,%str( ));
   proc sql noprint;
     select count(*) into :_count trimmed from &_stage
     where upcase(rownames)=upcase("%superq(_gene)");
   quit;
   %if &_count=0 %then %do;
     %put ERROR: GTEX_CACHE_ONLY: Gene %superq(_gene) has no rows after filtering.;
     %let _bad=1;
   %end;
 %end;
 %if &_bad %then %do;
   proc datasets library=work nolist; delete &_tag; quit;
   %return;
 %end;
 data &dsdout; set &_stage; run;
 ods graphics on / width=&boxplot_width height=&boxplot_height;
 title 'GTEx expression from prepared gene subset';
 proc sgpanel data=&dsdout;
   panelby rownames / columns=1 novarname;
   vbox exp / category=cluster group=&_group groupdisplay=cluster;
   rowaxis label='Expression (scale preserved from cache)';
 run;
 title;
 proc datasets library=work nolist; delete &_tag; quit;
 %put NOTE: GTEX_CACHE_ONLY: Created &dsdout from &_source without downloading a matrix or modifying the cache.;
%mend;
