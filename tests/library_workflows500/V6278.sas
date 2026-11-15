/* New workflow V6278; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6278i;
length gene $80;
gene='allele01';ref=2;alt=27;output;
gene='allele02';ref=9;alt=15;output;
gene='allele03';ref=26;alt=20;output;
gene='allele04';ref=18;alt=10;output;
gene='allele05';ref=19;alt=7;output;
gene='allele06';ref=3;alt=9;output;
gene='allele07';ref=21;alt=19;output;
run;
%n26_calculate_binomial_P(dsdin=v6278i,dsdout=v6278o,Allele1_var=ref,Allele2_var=alt,TotReadCutoff=2);
data v6278m(keep=metric value);set v6278o;length metric $120;array measured[*] tot_reads binomial_P logP Ref_Frq A1A2log2Ratio;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6278m;set v6278m;format value best32.;run;
proc export data=v6278m outfile="%sysfunc(pathname(work))/V6278.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6278;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6278:;quit;
