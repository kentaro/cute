package Cute::View;
use strict;
use warnings;
use parent qw(Cute::Class);

use Tiffany;

__PACKAGE__->mk_accessors(qw(
    engine
    option
    template
));

sub init {
    my $self = shift;
       $self->template = Tiffany->load(
           $self->engine || 'Text::Xslate',
           $self->option || {},
       );
}

sub render {
    my ($self, $template_file, $args) = @_;
    $self->template->render($template_file, $args || {});
}

!!1;
