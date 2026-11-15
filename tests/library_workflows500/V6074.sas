/* New workflow V6074; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6074i;
length gene $80;
gene='gene01';c1=33.13;c2=8.200000000000001;c3=6.27;c4=21.34;c5=30.41;c6=-25.52;output;
gene='gene02';c1=11.26;c2=67.33;c3=-8.6;c4=16.470000000000002;c5=66.54;c6=46.61;output;
gene='gene03';c1=-9.61;c2=-16.54;c3=61.53;c4=-11.399999999999999;c5=67.67;c6=52.74;output;
run;
%n26_Zscore4matrix(dsdin=v6074i,rowwide=0,ByVar4rowwide=gene,dsdout=v6074o);
data v6074m(keep=metric value);set v6074o;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6074m;set v6074m;format value best32.;run;
proc export data=v6074m outfile="%sysfunc(pathname(work))/V6074.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6074;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6074:;quit;
