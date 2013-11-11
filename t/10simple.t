use strict;
use warnings;

use Test::More;
use Test::Fatal;
use lib 't/lib';

BEGIN {
    eval "use YAML::Syck ()";
    if($@) {
        eval "use YAML ()";
        if($@) {
            plan skip_all => "YAML or YAML::Syck required for this test";
        }
    }

    plan tests => 6;

    use_ok('MXSimpleConfigTest');
}

# Does it work with no configfile and not barf?
is(
    exception { MXSimpleConfigTest->new(req_attr => 'foo') },
    undef,
    'Did not die with no configfile specified',
);

# Can it load a simple YAML file with the options
{
    open(my $test_yaml, '>', 'test.yaml')
      or die "Cannot create test.yaml: $!";
    print $test_yaml "direct_attr: 123\ninherited_ro_attr: asdf\nreq_attr: foo\n";
    close($test_yaml);

    my $foo;
    is(
        exception { $foo = MXSimpleConfigTest->new_with_config(configfile => 'test.yaml') },
        undef,
        'Did not die with good YAML configfile',
    );

    is($foo->req_attr, 'foo', 'req_attr works');
    is($foo->direct_attr, 123, 'direct_attr works');
    is($foo->inherited_ro_attr, 'asdf', 'inherited_ro_attr works');
}

END { unlink('test.yaml') }
