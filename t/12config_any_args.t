use strict;
use warnings;

use lib 't/lib';

use Test::More tests => 6;
use Test::Requires 'Config::General';
use Test::Fatal;
use File::Temp 'tempdir';
use File::Spec::Functions;

BEGIN {
    use_ok('MXDriverArgsConfigTest');
}

# Does it work with no configfile and not barf?
{
    eval { MXDriverArgsConfigTest->new(req_attr => 'foo') };
    ok(!$@, 'Did not die with no configfile specified')
        or diag $@;
}

# Can it load a simple YAML file with the options
{
    my $tempdir = tempdir(DIR => 't', CLEANUP => 1);
    my $configfile = catfile($tempdir, 'test.conf');

    open(my $test_conf, '>', $configfile)
      or die "Cannot create $configfile: $!";
    print $test_conf <<EOM;
Direct_Attr 123
Inherited_Ro_Attr asdf
Req_Attr foo
EOM
    close($test_conf);

    my $foo;
    is(
        exception { $foo = MXDriverArgsConfigTest->new_with_config(configfile => $configfile) },
        undef,
        'Did not die with good General configfile',
    );

    is($foo->req_attr, 'foo', 'req_attr works');
    is($foo->direct_attr, 123, 'direct_attr works');
    is($foo->inherited_ro_attr, 'asdf', 'inherited_ro_attr works');
}
