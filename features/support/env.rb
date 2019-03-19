# Any 'run once' setup should go here as this file is evaluated
# when the environment loads.
# Any helper functions added here will be available in step
# definitions

RUNNING_CI = ENV['TRAVIS'] == 'true'
RUNNING_MAC = ENV['MAZE_OS'] == 'mac'

if RUNNING_MAC
  Dir.chdir('features/fixtures/macos-swift-cocoapods') do
    run_required_commands([
      ['bundle', 'install'],
      ['bundle', 'exec', 'pod', 'install'],
      ['../../scripts/build_mac_app.sh'],
    ])
  end
else
  Dir.chdir('features/fixtures/ios-swift-cocoapods') do
    run_required_commands([
      ['bundle', 'install'],
      ['bundle', 'exec', 'pod', 'install'],
      ['../../scripts/build_ios_app.sh'],
      ['../../scripts/remove_installed_simulators.sh'],
      ['../../scripts/launch_ios_simulators.sh'],
      ['../../scripts/pre_launch.sh'],
    ])
  end
end

# Helper to find report files on disk
def report_file_glob
  if RUNNING_MAC
    "#{ENV['HOME']}/Library/Caches/KSCrashReports/macOSTestApp/*.json"
  else
    app_path = `xcrun simctl get_app_container booted com.bugsnag.iOSTestApp`.chomp
    app_path.gsub!(/(.*Containers).*/, '\1')
    "#{app_path}/**/KSCrashReports/iOSTestApp/*.json"
  end
end

# Scenario hooks
Before do
  # Name set in launch_ios_simulators.sh
  set_script_env('iOS_Simulator', 'maze-sim')
end

at_exit do
  if RUNNING_MAC
    run_required_commands([
      ['features/scripts/kill_mac_app.sh'],
    ])
  else
    run_required_commands([
      ['features/scripts/remove_installed_simulators.sh'],
    ])
  end
end
