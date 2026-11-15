/* New workflow W6936; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6936o;length gene $80;infile "E:/LongCOVID_HGI_GWAS/PGC_Large_GWASs/Manuscript4AI_with_PGC_GWASs/FR_Reviewers_Comments/perlMCP4Gemini_Paper/MCP4SAS/tests/online_samples500/inputs/n26_w6936.csv" dsd dlm="," firstobs=2 truncover;input gene $ x y;run;
data w6936m(keep=metric value);set w6936o;length metric $120;array measured[*] x y;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6936m;set w6936m;format value best32.;run;
proc export data=w6936m outfile="%sysfunc(pathname(work))/W6936.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6936;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6936:;quit;
