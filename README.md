# CS50 CLI

> A Docker-based command-line environment for CS50 workflows.

`cs50/cli` is a Docker image that provides a ready-to-use CS50 command-line environment on your local machine via the `cli50` tool. It lets you *mount a directory* in a Docker container running Ubuntu 22.04 so you can work on your projects without installing dependencies locally. :contentReference[oaicite:0]{index=0}

---

## Features

- Mount any directory into a container running `cs50/cli`  
- Fully contained Ubuntu 22.04 environment  
- Works with Docker outside Docker (DooD)  
- Useful for CS50 coursework development and testing  
- Exposes ports, supports dotfile mounts, and provides versatile flags for flexibility :contentReference[oaicite:1]{index=1}

---

## Installation

Before continuing, make sure you have installed:

1. **Docker** — for container runtime  
2. **Python ≥ 3.8** — required by `cli50`  
3. **pip** — Python’s package manager  

Install the CLI tool:
```bash
pip3 install cli50
```
To upgrade later:
```bash
pip3 install --upgrade cli50
```
After installing, you can pull and run the `cs50/cli` image via `cli50`.


> Check the documentation for more info: https://cs50.readthedocs.io/cli50/
