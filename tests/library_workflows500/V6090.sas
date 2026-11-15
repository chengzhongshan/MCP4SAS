/* New workflow V6090; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6090i;
length gene $80;
gene='gene01';c1=1.13;c2=-21.8;output;
gene='gene02';c1=32.26;c2=31.330000000000002;output;
gene='gene03';c1=-15.61;c2=33.46;output;
gene='gene04';c1=70.52;c2=32.59;output;
gene='gene05';c1=46.65;c2=21.72;output;
gene='gene06';c1=3.7800000000000002;c2=56.85;output;
run;
%n26_Zscore4matrix(dsdin=v6090i,rowwide=1,ByVar4rowwide=gene,dsdout=v6090o);
data v6090m(keep=metric value);set v6090o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6090m;set v6090m;format value best32.;run;
proc export data=v6090m outfile="%sysfunc(pathname(work))/V6090.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6090;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6090:;quit;
