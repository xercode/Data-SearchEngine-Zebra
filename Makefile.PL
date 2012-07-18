use strict;
use warnings;

use ExtUtils::MakeMaker 6.30;

my %WriteMakefileArgs = (
  "ABSTRACT" => "Data::SearchEngine backend for Zebra",
  "AUTHOR" => "Xercode github.com/xercode",
  "BUILD_REQUIRES" => {
    "Data::SearchEngine::Query" => 0,
    "HTTP::Headers" => 0,
    "HTTP::Response" => 0,
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Data-SearchEngine-Zebra",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Data::SearchEngine::Zebra",
  "PREREQ_PM" => {
    "Clone" => 0,
    "Data::SearchEngine" => "0.16",
    "Data::SearchEngine::Item" => 0,
    "Data::SearchEngine::Query" => 0,
    "Data::SearchEngine::Paginator" => 0,
    "Data::SearchEngine::Results" => 0,
    "Data::SearchEngine::Results::Spellcheck::Suggestion" => 0,
    "MooseX::Storage" => 0,
    "Moose" => 0,
  },
  "VERSION" => "0.01",
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);

