/* New workflow V6336; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6336i;
length gene $80 c1 $80 c2 $80 c3 $80;
gene='gene01';c1='68.13';c2='-18.8';c3='29.27';output;
gene='gene02';c1='-0.74';c2='64.33';c3='-19.599999999999998';output;
gene='gene03';c1='4.39';c2='3.46';c3='-27.47';output;
gene='gene04';c1='-12.48';c2='-3.41';c3='26.66';output;
gene='gene05';c1='-4.35';c2='45.72';c3='41.79';output;
run;
%n26_char2num_dsd(dsdin=v6336i,vars=c1 c2 c3,dsdout=v6336o);
data v6336m(keep=metric value);set v6336o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6336m;set v6336m;format value best32.;run;
proc export data=v6336m outfile="%sysfunc(pathname(work))/V6336.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6336;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6336:;quit;
