# espeakeasy.pl
#
# Simple text-to-speech plugin for libpurple
#
# Do whatever you want with it :)

use Purple;

%PLUGIN_INFO = (
    perl_api_version => 2,
    name => "Espeakeasy",
    version => "0.1",
    summary => "Simple text-to-speech plugin using espeak",
    description => "Simple text-to-speech plugin using espeak",
    author => "Sean Yeh, cipibad",
    url => "",
    load => "plugin_load",
    unload => "plugin_unload",
);



sub plugin_init {
    return %PLUGIN_INFO;
}

sub plugin_load {
    $plugin = shift;

    Purple::Debug::info("espeakeasy", "plugin_load() - begin\n");

    # A pointer to the handle to which the signal belongs
    $convs_handle = Purple::Conversations::get_handle();
    Purple::Debug::info("espeakeasy", "Purple::Conversations::get_handle() - " . ($convs_handle ? "ok." : "fail.") . "\n");

    # Connect the perl sub 'receiving_im_msg_cb' to the event 'receiving-im-msg'
    Purple::Signal::connect($convs_handle, "receiving-im-msg", $plugin, \&receiving_im_msg_cb, "yyy");

    Purple::Debug::info("espeakeasy", "plugin_load() - espeakeasy plugin loaded\n");

}

sub plugin_unload {
    my $plugin = shift;
    Purple::Debug::info("espeakeasy", "plugin_unload() - espeakeasy plugin unloaded.\n");
}


sub receiving_im_msg_cb {
    my ($account, $who, $msg, $conv, $flags) = @_;

    my $buddy = Purple::Find::buddy($account, $who);
    $name = $buddy->get_alias() || $buddy->get_name();

    $name =~ s/"/''/g;

    $name =~ /\(([^)]*)\)/;
    $country = $1;

    $lang = "";
    $says = "says";

    if ( $country =~ /RO/ )
    {
        $lang = "-v ro";
        $says = "spune";
    }

    $name =~ s/\([^)]*\)//g;

    $msg  =~ s/<[^>]*>//g;
    $msg  =~ s/&nbsp;//g;

    $spoken = "$name $says $msg";
    system(("espeak -z " . $lang . " \"$spoken\" --stdout | aplay"));
}

