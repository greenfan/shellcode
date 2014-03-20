#!/usr/bin/perl -w
#Original author Shawn Bater
use strict;

#original length value=288
my $LENGTH = 2016;
my @history;
my $count = -1;

if(open(HISTORY, "<", "/mail/tmp/snapshot.txt")) {
	while(my $line = <HISTORY>) {
		$count++ if($line =~ /^top -/);
		if($history[$count]) {
			$history[$count] .= $line;
		} else {
			$history[$count] = $line;
		}
	}
	close(HISTORY);
}

$history[++$count] = '';

$ENV{TERM} = "linux";
open(TOP, "-|", "/usr/bin/top -b -n 1") or die;
while(my $line = <TOP>) {
	$history[$count] .= $line;
}
close(TOP);

while(scalar(@history) > $LENGTH) {
	shift @history;
}

open(HISTORY, ">", "/mail/tmp/snapshot.txt") or die;
my $date = localtime();
print HISTORY @history;
print HISTORY "RESULT END FOR $date \n";
print HISTORY "\n\n";
close(HISTORY);
   
