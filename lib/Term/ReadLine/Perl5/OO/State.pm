package Term::ReadLine::Perl5::OO::State;

use Class::Accessor::Lite 0.05 (
    rw => [qw(buf pos cols prompt oldpos maxrows query)],
);

sub new {
    my $class = shift;
    bless {
        buf => '',
        pos => 0,
        history_index => 0,
        oldpos => 0,
        maxrows => 0,
    }, $class;
}
use Text::VisualWidth::PP 0.03 qw(vwidth);

sub len { length(shift->buf) }
sub plen { length(shift->prompt) }

sub vpos {
    my $self = shift;
    vwidth(substr($self->buf, 0, $self->pos));
}

sub width {
    my $self = shift;
    vwidth($self->prompt . $self->buf);
}

1;
