# md5_rsrc
## Compute the MD5 hash of the resource fork of a file

On a Mac (particularly on the HFS, HFS+, and APFS file systems), every file has two forks: a data fork, and a resource fork. The resource fork isn't used for much anymore, but on the Classic Mac OS, applications and the operating system kept essential resources there.

Modern systems have plenty of tools for computing various hashes of files for verifying data integrity and detecting data loss, including MD5, but they'll only read the data fork. It is possible to direct them to the resource fork, but since they don't understand the resource fork, this can cause false mismatches.

On Classic Mac OS, there's an app called [Checksum](https://macintoshgarden.org/apps/checksum-13) that enables separately hashing the data fork and resource fork of a file. The documentation makes an interesting note: Since 112 bytes of the resource fork are reserved by the system (see “Inside Macintosh: Volume I”, page I-128), they cannot be relied upon for hashing purposes.

Checksum's manual calls this section “the Finder information portion of the resource fork”, implying that the Finder may alter that section at unspecified times. Checksum, in computing its MD5 hash of the resource fork, substitutes 112 zero-bytes in place of that portion of the fork. 

This tool does the same thing. Give it a file, and it will compute the MD5 hash of its resource fork, with the same substitution of zero-bytes for those 112 bytes.

I've confirmed that this obtains the same MD5 hashes as Checksum.

### Setting up Checksum to give you the MD5 hash of the resource fork

You'll need the Classic Mac OS, either running under an emulator such as SheepShaver, or on a real Mac. [Grab Checksum from the Macintosh Garden](https://macintoshgarden.org/apps/checksum-13) and install it on Classic Mac OS. The Macintosh Garden listing says it works on System 6 through Mac OS 9.2.2; I use it on Mac OS 9.0.4 in SheepShaver.

In Checksum's Options menu, make the following choices:

- RSA MD5
- Resource fork: On
- Data fork: (up to you)
- 'TEXT' special: Off

In the Preferences dialog, turn on “Report file forks separately”.

You should then have Checksum giving you the hash of the data fork and the hash of the resource fork, in that order, separated by a plus sign, for each file you hash with it.

### Comparing Checksum output to hashes from the modern world

To compute the MD5 of the data fork of a file, use `openssl md5 path/to/file`.

To compute the MD5 of the resource fork of a file, use `md5_rsrc path/to/file`.

(Note that you do not need to, and in fact should not, append `/..namedfork/rsrc`. md5_rsrc will do that for you. It will not access the data fork.)

The hash you get from `openssl md5` should match the first hash Checksum gives you, and the hash you get from `md5_rsrc` should match the second.

### Why MD5? Why not SHA-something-or-other?

The Checksum application for Classic Mac OS doesn't support SHA-1, much less any of the newer SHAs, and it's unlikely to receive any updates to add those functions. This tool is specifically for comparing Checksum's output to MD5 hashes of files computed in the modern world.

If you're not trying to compare files in the modern world to files on a Classic Mac OS system, you don't need this and should probably use a more robust hash.

You should not use MD5 to verify that a file hasn't been tampered with intentionally. MD5 is, here in 2023, thoroughly compromised—an attacker can fool it. You should only use this tool if you're transporting files yourself between Classic Mac OS and a modern system and want to verify that the file isn't getting _accidentally_ damaged.
