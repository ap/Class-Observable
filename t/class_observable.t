use strict; use warnings;

use Test::More tests => 17;
use Class::Observable;

use lib 't/lib';
use Song;
use DeeJay;

my @playlist = ( Song->new( 'U2', 'One' ),
                 Song->new( 'Moby', 'Ah Ah' ),
                 Song->new( 'Aimee Mann', 'How Am I Different' ),
                 Song->new( 'Everclear', 'Wonderful' ) );
my $dj      = DeeJay->new( \@playlist );
my $dj_moby = DeeJay::Selfish->new( 'Moby' );
my $dj_help = DeeJay::Helper->new();
is( Song->add_observer( $dj ), 1,
    'Add main class-level observer' );
is( Song->add_observer( $dj_moby ), 2,
    'Add secondary class-level observer' );
is( $playlist[0]->add_observer( $dj_help ), 1,
    'Add object-level observer' );

is( Song->count_observers, 2,
    'Count class-level observers' );
is( $playlist[0]->count_observers, 3,
    'Count object-level + class-level observers' );

$dj->start_party;

is( $dj->num_updates, 2 * @playlist,
    'Main DJ got notified of start and end for all songs...' );
is( $dj->num_updates_stop, 1 * @playlist,
    '... and for the end of them all' );
is( $dj_moby->num_updates, 2 * @playlist,
    'Secondary DJ got notified of start and end for all songs...' );
is( $dj_moby->num_updates_self, do { 2 * grep $_->{'band'} eq 'Moby', @playlist },
    '... and recognised updates for his own songs' );
is( $dj_help->num_updates, 2,
    'Guest got notified about start and end of the song instance he was interested in' );

my $num_observers_copied = eval {
    $playlist[0]->copy_observers( $playlist[1] )
};
ok( ! $@, 'Copied observers run' );
is( $num_observers_copied, 3,
    'Copied correct number of observers' );
is( $playlist[1]->count_observers, 5,
    'New object has correct number of observers' );

is( $playlist[0]->delete_all_observers, 1,
    'Delete object-level observers' );
is( $playlist[1]->delete_all_observers, 3,
    'Delete object-level observers' );
is( Song->delete_observer( $dj ), 1,
    'Delete object from class-level observers' );
is( Song->delete_all_observers, 1,
    'Delete remaining class-level observers' );
