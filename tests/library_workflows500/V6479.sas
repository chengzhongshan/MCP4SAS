/* New workflow V6479; invented deterministic fixtures, not research results. */
options notes merror serror;
%n26_ImportFileHeadersFromZIP(zip=E:/LongCOVID_HGI_GWAS/PGC_Large_GWASs/Manuscript4AI_with_PGC_GWASs/FR_Reviewers_Comments/perlMCP4Gemini_Paper/MCP4SAS/tests/library_workflows500/inputs/n26_v6479.zip,filename_rgx=tsv[[:space:]]*$,obs=max,sasdsdout=v6479o,deleteZIP=0,use_zcat=0,infile_command=%str(firstobs=2 obs=12 delimiter="09"x dsd truncover;length gene $80;input gene $ measure;));
data v6479m(keep=metric value);set v6479o;length metric $120;array measured[*] measure;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6479m;set v6479m;format value best32.;run;
proc export data=v6479m outfile="%sysfunc(pathname(work))/V6479.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6479;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6479:;quit;
