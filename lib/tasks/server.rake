namespace_with_fontana :server, :libgss_test do
  desc "luanch HTTP server"
  fontana_task :launch_http_server

  desc "luanch HTTP server daemon"
  fontana_task :launch_http_server_daemon

  desc "luanch HTTPS server"
  fontana_task :launch_https_server

  desc "luanch HTTPS server daemon"
  fontana_task :launch_https_server_daemon

  desc "luanch server"
  fontana_task :launch_server

  desc "luanch server daemons"
  fontana_task :launch_server_daemons

  desc "shutdown server daemons"
  fontana_task :shutdown_server_daemons

  desc "check daemon alive"
  fontana_task :check_daemon_alive
end
