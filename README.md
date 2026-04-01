# Metasploit SMB Share Anonymous Brute Force Module

A Metasploit Framework auxiliary scanner module that brute-forces SMB share names using anonymous (null session) access. This module leverages `smbclient` to efficiently discover accessible shares on target systems without authentication.

## Overview

This module attempts to identify SMB shares on a target system that allow anonymous access. It reads a custom wordlist of share names and tests each one for accessibility using null sessions. This is useful for reconnaissance and identifying potential data exposure vulnerabilities in SMB-enabled environments.

## Installation

1. Copy the module to your Metasploit modules directory:

```bash
sudo cp smb-anonymous-share-bruteforce.rb /usr/share/metasploit-framework/modules/auxiliary/scanner/smb/
```

2. Reload modules in msfconsole:

```
msf > reload_all
```

## Requirements

- Metasploit Framework
- `smbclient` utility (part of Samba package)
- Valid wordlist file with share names (one per line)

## Usage

### Basic Usage

```
msf > use auxiliary/scanner/smb/smb_anonymous_share_bruteforce
msf auxiliary(smb_anonymous_share_bruteforce) > set RHOSTS 192.168.1.100
msf auxiliary(smb_anonymous_share_bruteforce) > set WORDLIST /path/to/shares.txt
msf auxiliary(smb_anonymous_share_bruteforce) > run
```

### With Verbose Output

```
msf auxiliary(smb_anonymous_share_bruteforce) > set VERBOSE true
msf auxiliary(smb_anonymous_share_bruteforce) > run
```

## Options

| Option   | Type   | Required | Default | Description                            |
| -------- | ------ | -------- | ------- | -------------------------------------- |
| RHOSTS   | string | Yes      | -       | Target host(s) or network range        |
| WORDLIST | path   | Yes      | -       | Path to the share names wordlist file  |
| VERBOSE  | bool   | No       | false   | Show failed attempts and error reasons |

## Wordlist Format

The wordlist should contain one share name per line. Common share names include:

```
admin$
c$
d$
print$
ipc$
backup
data
documents
invoices
shared
public
users
tmp
logs
```

## Example Output

### Successful Discovery

```
[*] Scanning 192.168.1.100 for anonymous shares...
[+] 192.168.1.100 - SUCCESS: Anonymous access to //192.168.1.100/backup
[+] 192.168.1.100 - SUCCESS: Anonymous access to //192.168.1.100/public
[*] Scanned 1 of 1 hosts (100% complete)
[*] Auxiliary module execution completed
```

### Verbose Mode

```
[*] Scanning 192.168.1.100 for anonymous shares...
[+] 192.168.1.100 - SUCCESS: Anonymous access to //192.168.1.100/backup
[*] 192.168.1.100 - FAILED: admin$ (ACCESS DENIED)
[*] 192.168.1.100 - FAILED: c$ (NO SUCH SHARE)
[+] 192.168.1.100 - SUCCESS: Anonymous access to //192.168.1.100/public
[*] 192.168.1.100 - FAILED: data (LOGON FAILURE)
[*] Scanned 1 of 1 hosts (100% complete)
[*] Auxiliary module execution completed
```

## Error Codes

The module recognizes and reports the following error conditions:

| Error         | Meaning                                     |
| ------------- | ------------------------------------------- |
| ACCESS DENIED | Share exists but anonymous access is denied |
| NO SUCH SHARE | Share name does not exist on the target     |
| LOGON FAILURE | Authentication or session failure           |
| UNKNOWN ERROR | Other SMB protocol errors                   |

## Results

Successful discoveries are automatically recorded in the Metasploit database with:

- **Type**: `smb.share.anonymous`
- **Host**: Target IP address
- **Data**: Discovered share name

These can be reviewed in Metasploit using:

```
msf > notes
```

## Troubleshooting

### smbclient not found

Ensure Samba is installed:

```bash
# Debian/Ubuntu
sudo apt-get install smbclient

# RHEL/CentOS
sudo yum install samba-client

# macOS
brew install samba
```

## Disclaimer

This module is designed for authorized security testing and penetration testing only. Unauthorized access to computer systems is illegal. Always obtain proper authorization before testing any system you do not own.
