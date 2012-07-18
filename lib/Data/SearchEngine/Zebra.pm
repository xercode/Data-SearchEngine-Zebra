package Data::SearchEngine::Zebra;

use Carp;
use ZOOM;
use XML::Simple;
use Data::Dumper;
use Moose;
use Data::SearchEngine::Zebra::Query;

with 'Data::SearchEngine';

use strict;
use warnings;

has conf_file => ( is => 'rw', isa => 'Str' );
has conf => ( is => 'rw' );
has _zconn => ( is => 'rw', isa => 'HashRef' );

sub search {
	my ($self, $query, $page, $count) = @_;
	
	$self->check_options();
	
	my $zconn = $self->zconn("biblio");

    my $z_query = new Data::SearchEngine::Zebra::Query->new(
                    zconn => $zconn,
                    query => "ti=a",
                    type => "CCL2RPN",
                    page  => $page,
                    count => $count,
                    query => $query
    );
    
	my $tmpresults = $zconn->search( $z_query->_zoom_query );
    
    return ($tmpresults, $zconn, $z_query);
}

sub BUILD {
    my $self = shift;

    # Use KOHA_CONF environment variable by default
    $self->conf_file( $ENV{KOHA_CONF} )  unless $self->conf_file;

    $self->conf( XMLin( $self->conf_file, 
        keyattr => ['id'], forcearray => ['listen', 'server', 'serverinfo'],
        suppressempty => '     ') );

    # Zebra connections 
    $self->_zconn( { biblio => undef, auth => undef } );
    
}

sub zconn {
    my ($self) = @_;

    my $zc = $self->_zconn->{$self->get_default("server")};

    return $zc  if $zc;

    my $c        = $self->conf;
    my $name     = $self->get_default("server") eq 'biblio' ? 'biblioserver' : 'authorityserver';
    my $syntax   = $self->get_default("syntax") || "usmarc";
    my $host     = $c->{listen}->{$name}->{content};
    my $user     = $c->{serverinfo}->{$name}->{user};
    my $password = $c->{serverinfo}->{$name}->{password};
    my $auth     = $user && $password;

    # set options
    my $o = new ZOOM::Options();
    if ( $user && $password ) {
        $o->option( user     => $user );
        $o->option( password => $password );
    }

    $o->option(async => 1) if ($self->get_default("async"));
    $o->option(count => $self->get_default("piggyback")) if ($self->get_default("piggyback"));
    $o->option( cqlfile => $c->{server}->{$name}->{cql2rpn} );
    $o->option( cclfile => $c->{serverinfo}->{$name}->{ccl2rpn} );
    $o->option( preferredRecordSyntax => $syntax );
    $o->option( elementSetName => "F"); # F for 'full' as opposed to B for 'brief'
    $o->option( databaseName => $self->get_default("server") eq 'biblio' ? "biblios" : "authorities");

    $zc = create ZOOM::Connection( $o );
    $zc->connect($host, 0);
    carp "something wrong with the connection: ". $zc->errmsg() if $zc->errcode;

    $self->_zconn->{$self->get_default("server")} = $zc;
    return $zc;
}

sub check_options{
    my $self = shift;
    croak "\"server\" option is not set!" unless ($self->get_default("server"));
}

sub find_by_id {
	
}

1;

=pod

=encoding UTF-8

=head1 NAME

Data::SearchEngine::Zebra - Zebra search engine abstraction.

=head1 VERSION

version 0.01

=head1 ATTRIBUTES

=head2 conf_file

Path to koha configuration file. If it's not set, KOHA_CONF will be used.

=head2 conf

Koha XML configuration file.

=head2 _zconn

Zebra connection.

=head1 METHODS

=head2 zconn

Return a connection to a Zebra server.

=head2 search

Returns:
    ResultSet from ZOOM::Connection::search
    Connection to a Zebra server
    Data::SearchEngine::Zebra::Query object

=head2 check_options

Check if all the required options are set.

=head1 AUTHOR

Juan Romay Sieira <juan.sieira@xercode.es>
Henri-Damien Laurent <henridamien.laurent@biblibre.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Xercode Media Software.
This software is Copyright (c) 2012 by Biblibre.

This is free software, licensed under:

    The GNU General Public License, Version 3, 29 June 2007

=cut