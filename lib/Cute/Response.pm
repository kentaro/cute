package Cute::Response;
use strict;
use warnings;
use parent qw(Plack::Response);

use HTTP::Status ();
use HTTP::Exception;
use Plack::Util::Accessor qw(path _template);

sub is_success {
    my $self = shift;
    HTTP::Status::is_success($self->code);
}

sub is_error {
    my $self = shift;
    HTTP::Status::is_error($self->code);
}

sub set_template {
    my ($self, $template) = @_;
    $self->_template($template);
}

sub template {
    my $self = shift;

    if (!$self->path || ($self->path && ref $self->path && $self->_template)) {
        HTTP::Exception->throw(404);
    }
    elsif (!$self->_template) {
        my ($template)  = $self->path =~ m{^/(.*)};
            $template ||= 'index';
            $template  .= '.html';
        $self->set_template($template);
    }

    $self->_template;
}

!!1;
