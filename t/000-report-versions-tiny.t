use strict;
use warnings;
use Test::More 0.88;
# This is a relatively nice way to avoid Test::NoWarnings breaking our
# expectations by adding extra tests, without using no_plan.  It also helps
# avoid any other test module that feels introducing random tests, or even
# test plans, is a nice idea.
our $success = 0;
END { $success && done_testing; }

# List our own version used to generate this
my $v = "\nGenerated by Dist::Zilla::Plugin::ReportVersions::Tiny v1.10\n";

eval {                     # no excuses!
    # report our Perl details
    my $want = '5.006';
    $v .= "perl: $] (wanted $want) on $^O from $^X\n\n";
};
defined($@) and diag("$@");

# Now, our module version dependencies:
sub pmver {
    my ($module, $wanted) = @_;
    $wanted = " (want $wanted)";
    my $pmver;
    eval "require $module;";
    if ($@) {
        if ($@ =~ m/Can't locate .* in \@INC/) {
            $pmver = 'module not found.';
        } else {
            diag("${module}: $@");
            $pmver = 'died during require.';
        }
    } else {
        my $version;
        eval { $version = $module->VERSION; };
        if ($@) {
            diag("${module}: $@");
            $pmver = 'died during VERSION check.';
        } elsif (defined $version) {
            $pmver = "$version";
        } else {
            $pmver = '<undef>';
        }
    }

    # So, we should be good, right?
    return sprintf('%-45s => %-10s%-15s%s', $module, $pmver, $wanted, "\n");
}

eval { $v .= pmver('CPAN::Changes','0.17') };
eval { $v .= pmver('Dist::Zilla::Plugin::Authority','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::CPANFile','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::ChangeStats::Git','v0.2.1') };
eval { $v .= pmver('Dist::Zilla::Plugin::CheckChangesHasContent','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::CoalescePod','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::CoderwallEndorse','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::ContributorsFile','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::ContributorsFromGit','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::Covenant','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::DOAP','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::Git','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::GithubMeta','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::HelpWanted','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::InstallGuide','1.200000') };
eval { $v .= pmver('Dist::Zilla::Plugin::InstallRelease','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::License','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::MatchManifest','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::MetaJSON','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::MetaProvides::Package','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::MetaYAML','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::ModuleBuild','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::NextRelease','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::NextVersion::Semantic','v0.1.2') };
eval { $v .= pmver('Dist::Zilla::Plugin::PodWeaver','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::PreviousVersion::Changelog','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::ReadmeFromPod','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::ReadmeMarkdownFromPod','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::ReportVersions::Tiny','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::RunExtraTests','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::SchwartzRatio','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::Signature','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::Test::Compile','2.033') };
eval { $v .= pmver('Dist::Zilla::Plugin::Test::UnusedVars','any version') };
eval { $v .= pmver('Dist::Zilla::Plugin::Twitter','0.025') };
eval { $v .= pmver('Dist::Zilla::Role::AfterRelease','any version') };
eval { $v .= pmver('Dist::Zilla::Role::FileMunger','any version') };
eval { $v .= pmver('Dist::Zilla::Role::MintingProfile::ShareDir','any version') };
eval { $v .= pmver('Dist::Zilla::Role::PluginBundle::Config::Slicer','any version') };
eval { $v .= pmver('Dist::Zilla::Role::PluginBundle::Easy','any version') };
eval { $v .= pmver('Dist::Zilla::Role::TextTemplate','any version') };
eval { $v .= pmver('Dist::Zilla::Role::VersionProvider','any version') };
eval { $v .= pmver('File::Spec','any version') };
eval { $v .= pmver('Git::Repository','any version') };
eval { $v .= pmver('IO::Handle','any version') };
eval { $v .= pmver('IPC::Open3','any version') };
eval { $v .= pmver('Module::Build','0.3601') };
eval { $v .= pmver('Moose','any version') };
eval { $v .= pmver('Perl::Version','any version') };
eval { $v .= pmver('Test::More','0.88') };
eval { $v .= pmver('strict','any version') };
eval { $v .= pmver('warnings','any version') };


# All done.
$v .= <<'EOT';

Thanks for using my code.  I hope it works for you.
If not, please try and include this output in the bug report.
That will help me reproduce the issue and solve your problem.

EOT

diag($v);
ok(1, "we really didn't test anything, just reporting data");
$success = 1;

# Work around another nasty module on CPAN. :/
no warnings 'once';
$Template::Test::NO_FLUSH = 1;
exit 0;
