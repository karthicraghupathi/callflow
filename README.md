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

#### macOS

- On macOS, install the dependencies using `brew`:
  ```
  brew install cmake gawk gnu-sed gnu-getopt
  brew cask install inkscape
  ```
- Ensure these dependencies are first by correctly setting `PATH` typically in your `.bashrc` or `.zshrc` files.

#### Ubuntu

- On Ubuntu, install the dependencies using `apt`:
  ```
  apt install gawk sed inkscape
  ```
- `getopt` should already be present on Debian based distros.
- Ensure these dependencies are first by correctly setting `PATH` typically in your `.bash_profile` file.

### Build Instructions

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

## Using `callflow`

With callflow in your path, just type:

```
callflow capture-file.cap
```

This will produce a directory named after your capture file in your working directory (eg: if file is `capture-file.cap`, the directory will be `capture-file`).

In this directory, you will find `callflow.svg`, `callflow.png` file, an `index.html` file and a `frames` directory.

Both the SVG file and the HTML file contain links into the frames directory so that you can look at the contents of the full packet frame.  All the frames have been processed to remove the IP headers, which usually aren't interesting.

Refer to the `man` page for the most complete and latest instructions.
