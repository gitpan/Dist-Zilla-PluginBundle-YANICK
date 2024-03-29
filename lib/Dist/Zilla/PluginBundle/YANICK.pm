package Dist::Zilla::PluginBundle::YANICK;
BEGIN {
  $Dist::Zilla::PluginBundle::YANICK::AUTHORITY = 'cpan:YANICK';
}
$Dist::Zilla::PluginBundle::YANICK::VERSION = '0.21.1';
# ABSTRACT: Be like Yanick when you build your dists

# [TODO] add CONTRIBUTING file


use strict;

use Moose;

with qw/
    Dist::Zilla::Role::PluginBundle::Easy
    Dist::Zilla::Role::PluginBundle::Config::Slicer
/;

has "doap_changelog" => (
    isa => 'Bool',
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;

        $self->payload->{doap_changelog} //= 1;
    },
);

sub configure {
    my ( $self ) = @_;
    my $arg = $self->payload;

    my $release_branch = 'releases';
    my $upstream       = 'github';

    my %mb_args;
    $mb_args{mb_class} = $arg->{mb_class} if $arg->{mb_class};
    $self->add_plugins([ 'ModuleBuild', \%mb_args ]);

    $self->add_plugins(
        qw/ 
            ContributorsFromGit
            ContributorsFile
            Test::Compile
            CoalescePod
            InstallGuide
            Covenant
        /,
        [ GithubMeta => { 
            remote => $upstream, 
            issues => 1,
        } ],
        qw/ MetaYAML MetaJSON PodWeaver License
          ReadmeFromPod 
          ReadmeMarkdownFromPod
          /,
        [ CoderwallEndorse => { users => 'yanick:Yanick' } ],
        [ NextRelease => { 
                time_zone => 'America/Montreal',
                format    => '%-9v %{yyyy-MM-dd}d',
            } ],
        'MetaProvides::Package',
        qw/ MatchManifest
          ManifestSkip /,
        [ 'Git::GatherDir' => {
                include_dotfiles => $arg->{include_dotfiles},
              } ],
        qw/ ExecDir
          PkgVersion /,
          [ Authority => { 
            ( authority => $arg->{authority} ) x !!$arg->{authority}  
          } ],
          qw/ ReportVersions::Tiny
          Signature /,
          [ AutoPrereqs => { 
                  ( skip => $arg->{autoprereqs_skip} ) 
                            x !!$arg->{autoprereqs_skip}
            } 
          ],
          qw/ CheckChangesHasContent
          TestRelease
          ConfirmRelease
          Git::Check
          /,
        [ 'Git::CommitBuild' => { 
                release_branch => $release_branch ,
                multiple_inheritance => 1,
        } ],
        [ 'Git::Tag'  => { tag_format => 'v%v', branch => $release_branch } ],
    );

    # Git::Commit can't be before Git::CommitBuild :-/
    $self->add_plugins(
        'PreviousVersion::Changelog',
        [ 'NextVersion::Semantic' => {
            major => 'API CHANGES',
            minor => 'NEW FEATURES, ENHANCEMENTS',
            revision => 'BUG FIXES, DOCUMENTATION, STATISTICS',
        } ],
        [ 'ChangeStats::Git' => { group => 'STATISTICS' } ],
        'Git::Commit',
    );

    if ( $ENV{FAKE} or $arg->{fake_release} ) {
        $self->add_plugins( 'FakeRelease' );
    }
    else {
        $self->add_plugins(
            [ 'Git::Push' => { push_to    => $upstream . ' master releases' } ],
            qw/ UploadToCPAN /, 
        );

        $self->add_plugins(
            [ Twitter => {
                tweet_url =>
                    'https://metacpan.org/release/{{$AUTHOR_UC}}/{{$DIST}}-{{$VERSION}}/',
                tweet => 
                    'Released {{$DIST}}-{{$VERSION}}{{$TRIAL}} {{$URL}} !META{resources}{repository}{web}',
                url_shortener => 'none',
            } ],
        ) if not defined $arg->{tweet} or $arg->{tweet};

        $self->add_plugins(
            [ 'InstallRelease' => { install_command => 'cpanm .' } ],
        );
    }
    
    $self->add_plugins(
    qw/
        SchwartzRatio 
    /,
        'Test::UnusedVars',
        'RunExtraTests',
    );

    if ( my $help_wanted = $arg->{help_wanted} ) {
        $self->add_plugins([
            'HelpWanted' => {
                map { $_ => 1 } split ' ', $help_wanted
            },
        ]);
    }

    $self->add_plugins( 
        [ DOAP => { 
            process_changes => $self->doap_changelog,
#            ttl_filename => 'project.ttl',
        } ],
        [ 'CPANFile' ],
    );

    $self->config_slice( 'mb_class' );

    return;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::PluginBundle::YANICK - Be like Yanick when you build your dists

=head1 VERSION

version 0.21.1

=head1 DESCRIPTION

This is the plugin bundle that Yanick uses to release
his distributions. It's roughly equivalent to

    [ContributorsFromGit]
    [ContributorsFile]

    [Test::Compile]

    [CoalescePod]

    [ModuleBuild]

    [InstallGuide]
    [Covenant]

    [GithubMeta]
    remote=github

    [MetaYAML]
    [MetaJSON]

    [PodWeaver]

    [License]
    [HelpWanted]

    [ReadmeFromPod]
    [ReadmeMarkdownFromPod]

    [CoderwallEndorse]
    users = yanick:Yanick

    [NextRelease]
    time_zone = America/Montreal

    [MetaProvides::Package]

    [MatchManifest]
    [ManifestSkip]

    [Git::GatherDir]
    [ExecDir]

    [PkgVersion]
    [Authority]

    [ReportVersions::Tiny]
    [Signature]

    [AutoPrereqs]

    [CheckChangesHasContent]

    [TestRelease]

    [ConfirmRelease]

    [Git::Check]

    [PreviousVersion::Changelog]
    [NextVersion::Semantic]

    [ChangeStats::Git]
    group=STATISTICS

    [Git::Commit]
    [Git::CommitBuild]
        release_branch = releases
        multiple_inheritance = 1
    [Git::Tag]
        tag_format = v%v
        branch     = releases

    [UploadToCPAN]

    [Git::Push]
        push_to = github master releases

    [InstallRelease]
    install_command = cpanm .

    [Twitter]
    [SchwartzRatio]


    [RunExtraTests]
    [Test::UnusedVars]

    [DOAP]
    process_changes = 1

    [CPANFile]

=head2 ARGUMENTS

=head3 autoprereqs_skip

Passed as C<skip> to AutoPrereqs.

=head3 authority

Passed to L<Dist::Zilla::Plugin::Authority>.

=head3 fake_release

If given a true value, uses L<Dist::Zilla::Plugin::FakeRelease>
instead of 
L<Dist::Zilla::Plugin::Git::Push>,
L<Dist::Zilla::Plugin::UploadToCPAN>,
L<Dist::Zilla::Plugin::InstallRelease> and
L<Dist::Zilla::Plugin::Twitter>.

Can also be triggered via the I<FAKE> environment variable.

=head3 mb_class

Passed to C<ModuleBuild> plugin.

=head3 include_dotfiles

For C<Git::GatherDir>. Defaults to false.

=head3 tweet

If a tweet should be sent. Defaults to C<true>.

=head3 doap_changelog

If the DOAP plugin should generate the project history
off the changelog. Defaults to I<true>.

=head1 AUTHOR

Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
