#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Warn;
use DBIx::Class::Carp;
use lib 't/lib';

warnings_exist {
  DBIx::Class::frobnicate();
} [
  qr/carp1/,
  qr/carp2/,
  qr/carp3/,
], 'expected warnings from carp_once';

warnings_exist {
  DBIx::Class::frobnicate();
} [qr/carp3/], 'carp_unique fires for new callsite';

warnings_are {
  DBIx::Class::branch1();
  DBIx::Class::branch2();
} [], 'still no warnings from carp_once again';

for (1, 0) {
   my $warning = '';
   local $SIG{__WARN__} = sub { $warning = shift };
   DBIx::Class::branch3();

   like($warning, ( $_
      ? qr/carp3/
      : qr/^$/
   ), ( $_
      ? 'first warning warns'
      : 'second is silent'
   ));
}

done_testing;

sub DBIx::Class::frobnicate {
  DBIx::Class::branch1();
  DBIx::Class::branch2();
  DBIx::Class::branch3();
}

sub DBIx::Class::branch1 { carp_once 'carp1' }
sub DBIx::Class::branch2 { carp_once 'carp2' }
sub DBIx::Class::branch3 { carp_unique 'carp3' }
