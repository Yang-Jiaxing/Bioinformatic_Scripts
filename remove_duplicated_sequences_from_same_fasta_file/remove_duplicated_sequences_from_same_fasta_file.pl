#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Data::Dumper;
$|=1;

my $global_options=&argument();
my $indir=&default("input","input");
my $outdir=&default("output","output");

my $osname=$^O;
if ($osname eq "MSWin32") {
	system("del/f/s/q $outdir") if (-e $outdir);
}elsif ($osname eq "cygwin") {
	system("rm -rf $outdir") if (-e $outdir);
}elsif ($osname eq "linux") {
	system("rm -rf $outdir") if (-e $outdir);
}elsif ($osname eq "darwin") {
	system("rm -rf $outdir") if (-e $outdir);
}
mkdir ($outdir) if (!-e $outdir);

my $i=0;
my $infile;
my $outfile;
while (defined ($infile=glob ($indir."/*.fasta"))){
	printf ("(%d)\tNow processing file => %s\t",++$i,$infile);
	$outfile=$outdir."/".substr ($infile,rindex ($infile,"/")+1);
	open (my $input,"<",$infile);
	open (my $output,">",$outfile);

	my (%hash,$header,$sequence);
	while (defined ($header=<$input>) and defined ($sequence=<$input>)) {
		$header=~ s/\r|\n//g;
		$sequence=~ s/\r|\n//g;
		if ((not $hash{$header}++) and (not $hash{$sequence}++)){#header not dup,sequence not dup
			print $output "$header\n$sequence\n";
		}elsif (($hash{$header}++) and (not $hash{$sequence}++)) {#header dup,sequence not dup
			print $output "$header\n$sequence\n";
		}
	}
	close $input;
	close $output;
	printf ("Output file => %s\n",$outfile);
}


##function##
sub argument{
	my @options=("help|h","input|i:s","output|o:s");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'h'} or $options{'help'});
	if(!exists $options{'input'}){
		print "***ERROR: No input directory is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'output'}){
		print "***ERROR: No output directory is assigned!!!\n";
		exec ("pod2usage $0");
	}
	return \%options;
}

sub default{
	my ($default_value,$option)=@_;
	if(exists $global_options->{$option}){
		return $global_options->{$option};
	}
	return $default_value;
}

__DATA__

=head1 NAME

    remove_duplicated_sequences_from_same_fasta_file.pl

=head1 COPYRIGHT

    copyright (C) 2018 Xiao-Jian Qu

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

=head1 DESCRIPTION

    remove duplicated sequences from same fasta file

=head1 SYNOPSIS

    remove_duplicated_sequences_from_same_fasta_file.pl -i -o
    Copyright (C) 2018 Xiao-Jian Qu
    Please contact <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]         help information.
    [-i -input]        required: (default: input) input directory name containing fasta files for each species.
    [-o -output]       required: (default: output) output directory name.

=cut
