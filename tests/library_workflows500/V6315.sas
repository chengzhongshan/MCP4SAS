/* New workflow V6315; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6315i;
length gene $80 c1 $80 c2 $80;
gene='gene01';c1='27.13';c2='35.2';output;
gene='gene02';c1='42.26';c2='35.33';output;
gene='gene03';c1='35.39';c2='53.46';output;
gene='gene04';c1='-22.48';c2='56.59';output;
run;
%n26_char2num_dsd(dsdin=v6315i,vars=c1,dsdout=v6315o);
data v6315m(keep=metric value);set v6315o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6315m;set v6315m;format value best32.;run;
proc export data=v6315m outfile="%sysfunc(pathname(work))/V6315.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6315;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6315:;quit;
