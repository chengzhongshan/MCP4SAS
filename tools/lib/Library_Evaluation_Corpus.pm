package Library_Evaluation_Corpus;
use strict; use warnings;
use File::Find qw(find); use File::Spec; use File::Path qw(make_path);
use Digest::SHA qw(sha256_hex); use JSON::PP;
sub write_corpus {
    my (%args)=@_; my ($library,$destination,$round,$letter,$start,$families)=@args{qw(library destination round letter start families)};
    die 'Expected 50 families' unless @$families==50;
    my @files;
    my @roots=$args{source_directories}?@{$args{source_directories}}:map {"SAS-Useful-Codes/$_"} qw(Easy-For-Error-Codes-SAS SAS_Code_Database Macros);
    my $extension=$args{source_extension}//'sas'; die 'Invalid source extension' unless $extension=~/^[a-z]+$/i;
    for my $sub (@roots) {
        my $dir=File::Spec->catdir($library,$sub); die "Missing $dir" unless -d $dir;
        find({no_chdir=>1,wanted=>sub {push @files,$File::Find::name if -f $_ && /\.\Q$extension\E$/i}},$dir);
    }
    my @passes=(1); push @passes,0 if grep {$_->{book_pattern}} @$families;
    for my $preferred (@passes) { for my $path (sort @files) {
        my @eligible=grep {!$_->{evidence} && (!$preferred || !$_->{book_pattern} || $path=~$_->{book_pattern})} @$families;
        next unless @eligible;
        open my $fh,'<:raw',$path or die "$path: $!"; local $/; my $source=<$fh>; close $fh;
        my $line=0;
        for my $text (split /\n/,$source) {
            ++$line;
            for my $family (@eligible) {
                next if $family->{evidence};
                if ($text =~ $family->{pattern}) {
                    my $relative=File::Spec->abs2rel($path,$library); $relative=~s{\\}{/}g;
                    $family->{evidence}={path=>$relative,line=>$line,source_sha256=>sha256_hex($source),evidence_sha256=>sha256_hex($text)};
                    $family->{evidence}{derived_extension}=JSON::PP::true if $family->{derived_extension};
                    if (($args{source_kind}//'') eq 'book_sample') {
                        (my $title=$relative)=~s{.*/}{}; $title=~s/\.txt$//i;
                        $family->{evidence}{book_title}=$title; $family->{evidence}{source_kind}='book_sample';
                    }
                }
            }
        }
        last unless grep {!$_->{evidence}} @$families;
    } }
    die 'Missing evidence: '.join(',',map {$_->{name}} grep {!$_->{evidence}} @$families)."\n" if grep {!$_->{evidence}} @$families;
    my (@cases,@programs,%seen,$negative_count);
    for my $family (@$families) {
        for my $n (2..11) {
            my $id=sprintf '%s%04d',$letter,$start+@cases; my $prefix=lc $id; my $body=$family->{body};
            my %replace=('@P@'=>$prefix,'@N@'=>$n,'@NP1@'=>$n+1,'@NP2@'=>$n+2,'@NX2@'=>2*$n,'@NDIGITS@'=>length($n),'@XS@'=>'x'x$n);
            $body=~s/(\@(?:P|N|NP1|NP2|NX2|NDIGITS|XS)\@)/$replace{$1}/ge;
            my $negative=defined $family->{diagnostic}; ++$negative_count if $negative;
            my $expected=$negative?undef:$family->{oracle}->($n);
            my $tolerance=$family->{tolerance}//'1e-9';
            die "Invalid tolerance for $id" unless $tolerance=~/^\d+(?:\.\d+)?(?:e-?\d+)?$/i && $tolerance>0;
            my $assert=$negative?'':"data _null_; if 0 then set ${prefix}o nobs=rows;\nif rows ne 1 then put 'ERROR: ROUND${round}_ROWS=$id rows=' rows;\n"
                ."else do; set ${prefix}o; if not missing(actual) and abs(actual-($expected))<=$tolerance*max(1,abs($expected)) then put 'ROUND${round}_PASS=$id';\n"
                ."else put 'ERROR: ROUND${round}_FAIL=$id actual=' actual; end; stop; run;\n";
            my $source="/* $id $family->{name}, N=$n; source: $family->{evidence}{path}:$family->{evidence}{line} */\n$body\n$assert"
                ."proc datasets library=work nolist; delete ${prefix}:; quit;\n";
            my $canonical=$source; $canonical=~s{\A/\*[^\n]*\*/\n}{}; $canonical=~s/\Q$letter\E\d{4}/lc($letter).'CASE'/ige;
            my $fingerprint=sha256_hex($canonical); die "Duplicate $id" if $seen{$fingerprint}++;
            push @programs,["$destination/$id.sas",$source];
            push @cases,{id=>$id,file=>"$id.sas",family=>$family->{name},input_n=>$n,expected=>$expected,
                expected_failure=>$negative?JSON::PP::true:JSON::PP::false,diagnostic=>$family->{diagnostic},
                body_sha256=>$fingerprint,evidence=>$family->{evidence},tables_prefix=>$prefix,tolerance=>$tolerance};
        }
    }
    die 'Expected 500 cases' unless @cases==500;
    # Validate every oracle and fingerprint before replacing existing fixtures.
    # A generation error must not leave half a new corpus beside an old manifest.
    make_path($destination);
    for my $program (@programs) {
        open my $out,'>:raw',$program->[0] or die $!; print {$out} $program->[1]; close $out or die $!;
    }
    open my $mf,'>:raw',"$destination/manifest.json" or die $!;
    print {$mf} JSON::PP->new->canonical->pretty->encode({schema=>1,count=>500,round=>$round,
        success_cases=>500-($negative_count//0),expected_failure_cases=>$negative_count//0,description=>$args{description},cases=>\@cases});
    close $mf or die $!;
    print "Wrote 500 round-$round SAS evaluations to $destination\n";
}
1;
