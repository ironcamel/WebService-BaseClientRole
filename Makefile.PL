
# This file was automatically generated by Dist::Zilla::Plugin::MakeMaker v5.020.
use strict;
use warnings;



use ExtUtils::MakeMaker ;



my %WriteMakefileArgs = (
  "ABSTRACT" => "[DEPRECATED] A base role for quickly and easily creating web service clients",
  "AUTHOR" => "Naveed Massjouni <naveed\@vt.edu>",
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => 0
  },
  "DISTNAME" => "WebService-BaseClientRole",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "WebService::BaseClientRole",
  "PREREQ_PM" => {
    "HTTP::Request::Common" => 0,
    "HTTP::Response::Stringable" => 0,
    "JSON" => 0,
    "LWP::UserAgent" => 0,
    "Moo" => "1.005000",
    "Moo::Role" => 0
  },
  "TEST_REQUIRES" => {
    "File::Spec" => 0,
    "IO::Handle" => 0,
    "IPC::Open3" => 0,
    "Test::More" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.0008",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "File::Spec" => 0,
  "HTTP::Request::Common" => 0,
  "HTTP::Response::Stringable" => 0,
  "IO::Handle" => 0,
  "IPC::Open3" => 0,
  "JSON" => 0,
  "LWP::UserAgent" => 0,
  "Moo" => "1.005000",
  "Moo::Role" => 0,
  "Test::More" => 0,
  "strict" => 0,
  "warnings" => 0
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



