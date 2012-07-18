package Data::SearchEngine::Zebra::Query;

use Modern::Perl;
use Carp qw(croak carp);
use ZOOM;
use Data::Dumper;

use Moose;

extends 'Data::SearchEngine::Query';

has +query => ( is =>'rw');
has +type => ( is=>'rw' );
has +zconn => ( is=>'rw' );
has _zoom_query => ( is=>'rw' );

sub BUILD {
    my $self = shift;
    $self->_build_zoom_query($self->zconn, $self->type);
}

sub _build_zoom_query {
    my $self = shift;
    my $conn = shift;
    my $type = shift;

    $type ||= $self->type;
    $conn ||= $self->zconn;
    if ( $type !~ /PQF|CQL|CCL2RPN|CQL2RPN/i ) {
        carp "$type not implemented for zebra";
        return
    }
    if ( $type =~ /CCL2RPN|CQL2RPN/i ) {
        if ( !defined($conn) ) {
            carp "$type requires a connection to be processed";
            return
        }
    }
    $self->{_zoom_query} = eval { "ZOOM::Query::" . uc $type }->new( $self->query ,$conn);
}

1;

=pod

=encoding UTF-8

=head1 NAME

Data::SearchEngine::Zebra::Item - Zebra search engine abstraction.

=head1 VERSION

version 0.01

=head1 ATTRIBUTES

=head2 query

Query in original format

=head2 type

Type of query (CCL, PQF ...)

=head2 zconn

ZOOM connection

=head2 _zoom_query

Query as a L<ZOOM::Query> object

=head1 METHODS

=head2 _build_zoom_query

Creates the ZOOM::Query object

=head1 AUTHOR

Juan Romay Sieira <juan.sieira@xercode.es>
Henri-Damien Laurent <henridamien.laurent@biblibre.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Xercode Media Software.
This software is Copyright (c) 2012 by Biblibre.

This is free software, licensed under:

    The GNU General Public License, Version 3, 29 June 2007

=cut