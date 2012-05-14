#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Warn;
use DBIx::Class::Carp;
use lib 't/lib';

my $WARN = 1;

warnings_exist {
  DBIx::Class::frobnicate();
} [
  qr/carp1/,
  qr/carp2/,
], 'expected warnings from carp_once';

warnings_are {
  DBIx::Class::branch1();
  DBIx::Class::branch2();
} [], 'still no warnings from carp_once again';

$WARN = 0;

warnings_are {
  DBIx::Class::branch3();
  DBIx::Class::branch4();
} [], 'no warnings due to if-expression';

$WARN = 1;

warnings_exist {
  DBIx::Class::branch3();
  DBIx::Class::branch4();
} [
   qr/carp3/,
   qr/carp4/,
], 'got warnings';

warnings_are {
  DBIx::Class::branch3();
  DBIx::Class::branch4();
} [], 'no warnings due to warning already';

done_testing;

sub DBIx::Class::frobnicate {
  DBIx::Class::branch1();
  DBIx::Class::branch2();
}

sub DBIx::Class::branch1 { carp_once_if {$WARN} 'carp1' }
sub DBIx::Class::branch2 { carp_once_if {$WARN} 'carp2' }
sub DBIx::Class::branch3 { carp_once_if {$WARN} 'carp3' }
sub DBIx::Class::branch4 { carp_once_if {$WARN} 'carp4' }
