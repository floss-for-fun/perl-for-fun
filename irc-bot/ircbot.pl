#!/usr/bin/env perl

use strict;
use warnings;
use IO::Socket;

my $user="pff-ircbot";
my $nick=shift || "pff-ircbot";
my $server="chat.freenode.net";
my $port=6667;
my @channel=qw(kalamangga.net);

$SIG{INT} = \&quit_h;
$SIG{TERM} = \&quit_h;

print "Connecting to server : $server ";
my $sock = IO::Socket::INET->new(PeerAddr=>$server,PeerPort=>$port,Proto=>'tcp')
	or die "[error] $!\n";
print "[connected]\n";
$sock->print("USER $nick $user $user $user\n");
$sock->print("NICK $nick\n");
for my $channel (@channel) {
	$sock->print("JOIN #$channel\n");
};
while (<$sock>) {
	chomp;
	print "$_\n";
	ping_req($sock, $1) if /^PING\s*:(.*?)$/i;
};

sub quit_h {
	print "$!\n";
	close $sock;
	print "Disconnected from $server\n\n";
};
sub ping_req {
	my ($sock, $str) = @_;
	chomp($str);
	$sock->print("PONG $str\n");
	print "PONG $str\n";
	return;
}
