/* New workflow V6077; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6077i;
length gene $80;
gene='gene01';c1=7.13;c2=12.200000000000001;c3=-9.729999999999999;c4=52.34;output;
gene='gene02';c1=67.26;c2=45.33;c3=25.400000000000002;c4=5.47;output;
gene='gene03';c1=67.39;c2=13.46;c3=-25.47;c4=-1.4;output;
gene='gene04';c1=65.52;c2=-23.41;c3=25.66;c4=-10.27;output;
gene='gene05';c1=10.65;c2=13.72;c3=-27.21;c4=27.86;output;
gene='gene06';c1=-19.22;c2=-2.15;c3=42.92;c4=61.99;output;
run;
%n26_Zscore4matrix(dsdin=v6077i,rowwide=0,ByVar4rowwide=gene,dsdout=v6077o);
data v6077m(keep=metric value);set v6077o;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6077m;set v6077m;format value best32.;run;
proc export data=v6077m outfile="%sysfunc(pathname(work))/V6077.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6077;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6077:;quit;
