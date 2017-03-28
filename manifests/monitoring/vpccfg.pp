class rjil::monitoring::vpccfg {

  ## Add the name of the scripts you have added in files/monitor_scripts/
  ## Example: $monitors = ['monitor_xmpp.sh','monitor_cassandra.sh']
  $monitors=['contrail_control_introspect.sh','contrail_config_introspect.sh','rabbitmq_queue_monitor.sh']
  rjil::monitoring { $monitors:}
  package{'python-jpype':}

}


