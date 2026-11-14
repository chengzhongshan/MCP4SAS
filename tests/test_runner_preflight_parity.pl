use strict;use warnings;use FindBin;use Test::More;
for my $name(qw(run_sas_codes_or_files_in_ODA.pl run_sas_codes_or_script_in_ODA.pl)){
 open my$f,'<',"$FindBin::Bin/../$name"or die$!;my$s=do{local$/;<$f>};
 like($s,qr/if \(SAS_Source_Analysis::include_target_needs_runtime_resolution\(\$target\)\) \{.*?next;.*?my \$remote_target = normalize_remote_include_path/s,"$name defers dynamic target before remote resolution");
}
open my$f,'<',"$FindBin::Bin/../server.pl"or die$!;my$s=do{local$/;<$f>};like($s,qr/is_local_file_candidate\(\$sas_input\).*?-f \$sas_input/s,'server guards filesystem probe');require File::Compare; is(File::Compare::compare("$FindBin::Bin/../run_sas_codes_or_files_in_ODA.pl", "$FindBin::Bin/../run_sas_codes_or_script_in_ODA.pl"),0,'compatibility runners are byte-identical, as required by the installer');done_testing;
