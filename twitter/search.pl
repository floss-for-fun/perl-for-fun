#!/usr/bin/perl

use strict;
use Net::Twitter::Lite::WithAPIv1_1;
use Scalar::Util 'blessed';
use Data::Dumper;

# Fill this stuff
my $key = '';
my $secret = '';
my $token = '';
my $token_secret = '';

my $nt = '';
my $r = '';
eval{
 $nt = Net::Twitter::Lite::WithAPIv1_1->new(
   consumer_key        => $key,
   consumer_secret     => $secret,
   access_token        => $token,
   access_token_secret => $token_secret,
   ssl                 => 1,  ## enable SSL! ##
  );
 my $terms = '@ryht';      # Just a test term
 $r = $nt->search($terms);
 
};
print Dumper($r);
exit;
