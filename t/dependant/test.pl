#!/usr/bin/perl -w

use Data::SearchEngine::Zebra;
use Data::SearchEngine::Zebra::Results;
use Data::Dumper;

my $zebra = Data::SearchEngine::Zebra->new();

# OPTIONS
$zebra->set_default ("server", "biblio");
$zebra->set_default ("async", 1);
$zebra->set_default ("piggyback", 0);
$zebra->set_default ("syntax", "xml");

# ==========   TEST   ================================================

my $tmpresults;   # Resultset from ZOOM::Connection::search
my $zconn;        # Connection to a Zebra server
my $seq;          # Data::SearchEngine::Query object
my $page = 1;     # First page
my $perpag = 1;   # Number of results per page

while ($page < 2){
    ($tmpresults, $zconn, $seq) = $zebra->search("ti=a", $page, $perpag);
    my $zebraR = Data::SearchEngine::Zebra::Results->new( query => $seq, _zoom_resultset => $tmpresults );
    my ($res) = $zebraR->retrieve($zconn);
    warn Dumper($res);
    $page++;
}

