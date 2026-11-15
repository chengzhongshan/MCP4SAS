/* New workflow V6094; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6094i;
length gene $80;
gene='gene01';c1=62.13;c2=58.2;c3=42.27;c4=48.34;c5=63.410000000000004;c6=-12.52;output;
gene='gene02';c1=45.26;c2=-26.669999999999998;c3=-13.6;c4=8.47;c5=4.54;c6=53.61;output;
gene='gene03';c1=30.39;c2=-19.54;c3=56.53;c4=53.6;c5=49.67;c6=60.74;output;
run;
%n26_Zscore4matrix(dsdin=v6094i,rowwide=1,ByVar4rowwide=gene,dsdout=v6094o);
data v6094m(keep=metric value);set v6094o;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6094m;set v6094m;format value best32.;run;
proc export data=v6094m outfile="%sysfunc(pathname(work))/V6094.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6094;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6094:;quit;
