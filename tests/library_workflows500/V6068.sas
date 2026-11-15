/* New workflow V6068; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6068i;
length gene $80;
gene='gene01';c1=-3.87;c2=11.200000000000001;c3=20.27;c4=66.33999999999999;c5=52.410000000000004;output;
gene='gene02';c1=23.26;c2=10.33;c3=13.4;c4=58.47;c5=-25.459999999999997;output;
gene='gene03';c1=47.39;c2=35.46;c3=-1.4699999999999998;c4=18.6;c5=-18.33;output;
gene='gene04';c1=67.52;c2=-5.41;c3=64.66;c4=-12.27;c5=10.799999999999999;output;
run;
%n26_Zscore4matrix(dsdin=v6068i,rowwide=0,ByVar4rowwide=gene,dsdout=v6068o);
data v6068m(keep=metric value);set v6068o;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6068m;set v6068m;format value best32.;run;
proc export data=v6068m outfile="%sysfunc(pathname(work))/V6068.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6068;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6068:;quit;
