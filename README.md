# Callflow

The callflow sequence diagram generator is a collection of awk and shell scripts that will take a packet capture file that can be read by wireshark and produce a time sequence diagram. This is useful to view & debug SIP callflows or other network traffic.

See the [LICENSE](LICENSE) file to get an overview of the license applied on this software.

## Original Project Locations

Hosted at: https://sourceforge.net/projects/callflow/

Project Page: http://callflow.sourceforge.net/

This project was originally hosted at the location listed above. At the time of creating this repository, this project was still available at SourceForge from where I've imported it to GitHub.

## Authors

This is a list of the **original** Callflow authors (sorted by last name in alphabetical order).

Callflow is available thanks to the work of:

- Richard Bos
- Kevin Chmilar
- Alan Hawrylyshen
- Cullen Jennings
- Zoltan Miricz
- Arnaud Morin
- Jon Ringle

Newest Contributor:

- Karthic Raghupathi
  - I'm by no means an expert in `bash`, `awk`, `tshark` or any of the other tools used in these scripts.
  - I was searching for a SIP sequence diagram generator and stumbled upon `callflow`.
  - The version I downloaded from SourceForge would not run on my macOS Catalina (10.15.4) on 2020-05-23. This is my humble attempt at getting it to work and contributing back to the community.

## Installation Instructions

### Dependencies

- GNU `awk`
- GNU `sed`
- GNU `getopt`
- `cmake`
- Inkscape
- TShark

#### macOS

- On macOS, install the dependencies using `brew`:
  ```
  brew install cmake gawk gnu-sed gnu-getopt
  brew cask install inkscape wireshark
  ```
- Ensure these dependencies are first by correctly setting `PATH` typically in your `.bashrc` or `.zshrc` files.

#### Ubuntu

- On Ubuntu, install the dependencies using `apt`:
  ```
  apt install gawk sed
  ```
- `getopt` should already be present on Debian based distros.
- Ensure these dependencies are first by correctly setting `PATH` typically in your `.bash_profile` file.
- Install the latest version of Inkscape from their repo by running the following commands:
  ```
  add-apt-repository ppa:inkscape.dev/stable
  apt update && apt install inkscape tshark
  ```
  - If you don't have the latest version of Inkscape, you will get the following error:
    ```
    Unknown option --export-png
    ```
  - `--export-png` was changed to `--export-filename` in [v1.0](https://wiki.inkscape.org/wiki/index.php/Release_notes/1.0#Command_Line)

### Build Instructions

Download an archived version of `callflow` from the [releases](https://github.com/karthicraghupathi/callflow/releases) page and extract it.

Inside your `callflow` folder, run the following commands:

``` bash
mkdir build
cd build
cmake ..
make install
```

This will install the files in their default locations which is usually under `/usr/local`.

The file locations can be influenced by using the following arguments:

- `CMAKE_INSTALL_PREFIX`
- `CONFDIR`
- `DOCDIR`

For e.g., to install files under `/usr` instead of `/usr/local`, do this:

```
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr
make install
```

Package builders may want to use the commands:

```
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DDOCDIR=/usr/share/doc/package/callflow -DCONFDIR=/etc
make install DESTDIR=<package build directory>
```

### Docker Instructions

Docker images are available at https://hub.docker.com/r/karthicr/callflow.

#### First Run

With Docker installed, run the following command to have a running container having a working version of `callflow`:

```
docker run \
  --name callflow \
  -v /source/folder/containing/PCAPs:/PCAPs
  -it \
  karthicr/callflow:latest /bin/bash
```

- `--name callflow` creates a container called `callflow`
- `-v /source/folder/containing/PCAPs:/PCAPs` maps the source folder from your local machine to a folder called `PCAPs` inside your container. You will change into this folder inside your container to invoke `callflow`.
- `-it` keeps STDIN open and allocates a pseudo-TTY.
- `karthicr/callflow:latest` pulls the latest `callflow` image from the Docker registry
- `/bin/bash` is the command that is run when the container has booted resulting in an interactive shell for you to work with.

#### Subsequent Runs

Once the earlier command is issued, you will always have a `callflow` container ready to go. To use the existing container next time, run the following command:

```
docker exec -it callflow /bin/bash
```

## Using `callflow`

With callflow in your path, just type:

```
callflow capture-file.cap
```

This will produce a directory named after your capture file in your working directory (eg: if file is `capture-file.cap`, the directory will be `capture-file`).

In this directory, you will find `callflow.svg`, `callflow.png` file, an `index.html` file and a `frames` directory.

Both the SVG file and the HTML file contain links into the frames directory so that you can look at the contents of the full packet frame.  All the frames have been processed to remove the IP headers, which usually aren't interesting.

You will typically use the following command:

```
callflow -d --no-archive capture-file.cap
```

- `-d` removes duplicate frames while processing the PCAP files.
- `--no-archive` disables the creation of the archive containing the callflow. This option can also be configured in `callflow.conf` so you don't repeat it everytime you invoke `callflow`.

Refer to the `man` page for the most complete and latest instructions.
