/* New workflow V6483; invented deterministic fixtures, not research results. */
options notes merror serror;
%n26_ImportFileHeadersFromZIP(zip=E:/LongCOVID_HGI_GWAS/PGC_Large_GWASs/Manuscript4AI_with_PGC_GWASs/FR_Reviewers_Comments/perlMCP4Gemini_Paper/MCP4SAS/tests/library_workflows500/inputs/n26_v6483.tsv.gz,filename_rgx=tsv[[:space:]]*$,obs=max,sasdsdout=v6483o,deleteZIP=0,use_zcat=0,infile_command=%str(firstobs=4 obs=6 delimiter="09"x dsd truncover;length gene $80;input gene $ measure;));
data v6483m(keep=metric value);set v6483o;length metric $120;array measured[*] measure;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6483m;set v6483m;format value best32.;run;
proc export data=v6483m outfile="%sysfunc(pathname(work))/V6483.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6483;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6483:;quit;
