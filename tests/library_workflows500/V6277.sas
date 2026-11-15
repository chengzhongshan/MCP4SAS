/* New workflow V6277; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6277i;
length gene $80;
gene='allele01';ref=18;alt=28;output;
gene='allele02';ref=12;alt=2;output;
gene='allele03';ref=36;alt=33;output;
gene='allele04';ref=9;alt=10;output;
gene='allele05';ref=29;alt=9;output;
gene='allele06';ref=22;alt=6;output;
run;
%n26_calculate_binomial_P(dsdin=v6277i,dsdout=v6277o,Allele1_var=ref,Allele2_var=alt,TotReadCutoff=10);
data v6277m(keep=metric value);set v6277o;length metric $120;array measured[*] tot_reads binomial_P logP Ref_Frq A1A2log2Ratio;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6277m;set v6277m;format value best32.;run;
proc export data=v6277m outfile="%sysfunc(pathname(work))/V6277.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6277;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6277:;quit;
