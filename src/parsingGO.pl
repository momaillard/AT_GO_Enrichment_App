#!/usr/bin/env perl

=head1 NAME

Produce UniverseFile form TAIR GO annotations file.

=head2 SYNOPSIS

cat mySLIM_GO_FILE | ./parsing GO.pl

=head3 DESCRIPTION

parse TAIR GO SLIM FILE ( exemple ATH_GO_GOSLIM.txt.gz)to produce an "UniverseFile" as input for TOPGO R package.

=head4 OPTIONS

--Help|help|h, produces this help file.

--verbose[no-verbose]|Verbose[no-Verbose]|v[no-v], boolean option to print out warnings during execution. Warnings and errors are redirected to STDERR. Defaults to no-verbose (silent mode).


=head1 AUTHORS
Morgan MAILLARD

=head1 VERSION

1.00

=head1 DATE

05/02/2020

=cut

# libraries
use warnings;
use strict;
use Pod::Usage; # interpretation "=head1 XX" [language POD]
use Getopt::Long; #gestion des options
use File::Basename; # basename recupere le nom du fichier 
use Data::Dumper;
use 5.10.0;

# scalars
my $help;
my $verbose;
my $debug;			# debug purposes only
my $id;
my $goterm;

# list
my @ligneCourante;

# hashs
my %hashstockage;


# functions
sub error ($) {
	# management of error messages and help page layout, will stop execution
	# local arguments passed:	 1st, error message to output
	my $error = shift;
	my $filename = basename($0);
	pod2usage(-message => "$filename (error): $error Execution halted.", -verbose => 1, -noperldoc => 1);
	exit(2);
}

sub warning ($) {
	# management of warnings and execution carry on
	# local arguments passed:	 1st, warning message to output
	if ($verbose) {
		my $message = shift;
		my $filename = basename($0);
		warn("$filename (info): ".$message."\n");
	}
}

sub debug ($) {
	# management of debugging messages
	# local arguments passed:	 1st, warning message to output
	# no return value
	if ($debug) {
		my $message = shift;
		warn(Dumper($message));
	}
}

MAIN: {
	GetOptions(	"help|Help|H|h!"					=> \$help,
			"verbose|Verbose|v!"					=> \$verbose,
			"debug|d!"						=> \$debug
				);
	if ($help) {
		pod2usage(-verbose => 2, -noperldoc => 1);GO:
	exit;
	}

	warning("Processing table from STDIN...");
	while (my$line = <STDIN>){
	chomp($line);
    	@ligneCourante = split ("\t",$line);
    	$id = $ligneCourante[0];
    	$goterm = $ligneCourante[1];
    	$hashstockage{$id}{$goterm} = 1;
    	}
    
    	foreach my $keyid(keys %hashstockage){
        	print STDOUT "$keyid\t";
        	foreach my $keyGO ( keys %{$hashstockage{$keyid}}){
            	print STDOUT "$keyGO, ";
        	}
       	 print STDOUT "\n";
    	}
}




