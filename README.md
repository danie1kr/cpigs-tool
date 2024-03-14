
# cpigs-tool
Configure your ClockworkPI GameShell

# Description
The CPIGS-Tool is a bash script for controlling launcherGO entries for the [ClockworkPI GameShell](https://www.clockworkpi.com/gameshell).

It contains a set of modules in `modules` sub directory which can be queried using `cpigs-tool.sh --list`. Modules should have a description of their parameters and commands.
At the moment, the tool supports:

 - [DevilutionX](https://github.com/diasurgical/devilutionX), a Diablo build for modern operating systems
	 - Downloading, compiling+installing and running the game.
 - [RetroArch](https://github.com/libretro/RetroArch), a Cross-platform, sophisticated frontend for the libretro API
	 - Downloading, compiling+installing and linking any properly configured playlist game.
 - [moonlight-qt](https://github.com/moonlight-stream/moonlight-qt), a GameStream client for PCs
	 - Downloading, installing and linking a remote application.

The CPIGS-Tool requires a [modern armbian](https://github.com/uberlinuxguy/armbian-build) to run.

# Contribution
Just submit an issue or pull request with ideas! Any input is welcome.
## Writing new modules
Modules are put in the `modules` directory. Each modules registers with the `cpigs_register "mod"` in the way it is called.
Within each module, the `mod` function is called with the command line arguments when the user specifies the module in the cpigs parameter: `cpigs-tool.sh mod`.
Each module should accept the `text` parameter which is called when using `cpigs-tools.sh --list`, echoing a one line module description and a `--help` parameter telling the user about its capabilities.

# Have fun!
