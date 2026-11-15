/* New workflow V6078; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6078i;
length gene $80;
gene='gene01';c1=66.13;c2=-22.8;c3=67.27;c4=3.34;c5=23.41;output;
gene='gene02';c1=60.26;c2=-10.67;c3=0.4;c4=-14.53;c5=4.54;output;
gene='gene03';c1=14.39;c2=23.46;c3=4.529999999999999;c4=8.600000000000001;c5=10.67;output;
gene='gene04';c1=-15.48;c2=1.59;c3=0.66;c4=11.73;c5=45.800000000000004;output;
gene='gene05';c1=11.65;c2=29.72;c3=41.79;c4=11.860000000000001;c5=-19.07;output;
gene='gene06';c1=40.78;c2=26.85;c3=17.92;c4=46.99;c5=10.059999999999999;output;
gene='gene07';c1=50.91;c2=55.98;c3=31.05;c4=44.12;c5=-12.81;output;
run;
%n26_Zscore4matrix(dsdin=v6078i,rowwide=0,ByVar4rowwide=gene,dsdout=v6078o);
data v6078m(keep=metric value);set v6078o;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6078m;set v6078m;format value best32.;run;
proc export data=v6078m outfile="%sysfunc(pathname(work))/V6078.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6078;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6078:;quit;
