##
# This module requires Metasploit: https://metasploit.com
# This module can be found in Github: https://github.com/0x-d3v/msf-smb-anonymous-share-bruteforce
##

class MetasploitModule < Msf::Auxiliary
  include Msf::Exploit::Remote::SMB::Client
  include Msf::Auxiliary::Scanner
  include Msf::Auxiliary::Report

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'SMB Share Anonymous Brute Force (smbclient)',
      'Description'    => %q{
        This module enumerates SMB share names against a target host using a custom
        wordlist, attempting to identify shares accessible via anonymous (null session)
        access. Successful anonymous share access is reported and logged. Requires a
        wordlist of share names to test.
      },
      'Author'         => [ '0xDev' ],
      'License'        => MSF_LICENSE
    ))

    register_options(
      [
        OptPath.new('WORDLIST', [ true, "Path to the share names wordlist", nil ]),
        OptBool.new('VERBOSE', [ false, "Show failed attempts", false ])
      ]
    )
  end

  def run_host(ip)
    wordlist = datastore['WORDLIST']
    verbose  = datastore['VERBOSE']

    unless ::File.exist?(wordlist)
      print_error("Wordlist #{wordlist} not found")
      return
    end

    print_status("Scanning #{ip} for anonymous shares...")

    ::File.foreach(wordlist) do |share|
      share_name = share.strip
      next if share_name.empty?

      cmd = "smbclient -N //#{ip}/#{share_name} -c 'ls' 2>&1"
      output = `#{cmd}`

      if $?.success? && !output.include?("NT_STATUS")
        print_good("#{ip} - SUCCESS: Anonymous access to //#{ip}/#{share_name}")

        report_note(
          host: ip,
          type: 'smb.share.anonymous',
          data: "Share: #{share_name}",
          update: :unique_data
        )
      else
        # Only show failures if verbose is enabled
        if verbose
          reason =
            if output.include?("NT_STATUS_ACCESS_DENIED")
              "ACCESS DENIED"
            elsif output.include?("NT_STATUS_BAD_NETWORK_NAME")
              "NO SUCH SHARE"
            elsif output.include?("NT_STATUS_LOGON_FAILURE")
              "LOGON FAILURE"
            else
              "UNKNOWN ERROR"
            end

          print_status("#{ip} - FAILED: #{share_name} (#{reason})")
        end
      end
    end
  end
end

