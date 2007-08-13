use strict; use warnings;

use Test::More tests => 18;
use Class::Observable;

BEGIN {
    package Foo;
    our @ISA = qw( Class::Observable );
    sub new { return bless( {}, $_[0] ) }
    sub yodel { $_[0]->notify_observers }

    package Baz;
    our @ISA = qw( Foo );
    sub yell { $_[0]->notify_observers }
}

my @observations;
sub observer_a { push @observations, "Observation A from [" . ref( $_[0] ) . "]" }
sub observer_b { push @observations, "Observation B from [" . ref( $_[0] ) . "]" }
sub observer_c { push @observations, "Observation C from [" . ref( $_[0] ) . "]" }

is( Foo->add_observer( \&observer_a ), 1, "Add observer A to class" );
is( Baz->add_observer( \&observer_b ), 1, "Add observer B to class" );

is( Foo->count_observers, 1, "Count observers in class" );
is( Baz->count_observers, 2, "Count observers in class" );

my $foo = Foo->new;
$foo->yodel;
is( $observations[0], "Observation A from [Foo]", "Catch notification from parent" );
@observations = ();

my $baz_a = Baz->new;
$baz_a->yell;
is( $observations[0], "Observation B from [Baz]", "Catch notification from child" );
is( $observations[1], "Observation A from [Baz]", "Catch parent notification from child" );
@observations = ();

my $baz_b = Baz->new;
is( $baz_b->add_observer( \&observer_c ), 1, "Add observer C to object" );
is( $baz_b->count_observers, 3, "Count observers in object + class" );
$baz_b->yell;
is( $observations[0], "Observation C from [Baz]", "Catch notification (object) from child" );
is( $observations[1], "Observation B from [Baz]", "Catch notification (class) from child" );
is( $observations[2], "Observation A from [Baz]", "Catch parent notification from child" );
@observations = ();

my $baz_c = Baz->new;
$baz_c->yell;
is( $observations[0], "Observation B from [Baz]", "Catch notification from child (after object add)" );
is( $observations[1], "Observation A from [Baz]", "Catch parent notification from child (after object add)" );
@observations = ();

is( $baz_b->delete_all_observers, 1, 'Delete object observers' );
is( $baz_c->delete_all_observers, 0, 'Delete non-existent object observers' );
is( Baz->delete_all_observers, 1, 'Delete child observers' );
is( Foo->delete_all_observers, 1, 'Delete parent observers' );
