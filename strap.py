#!/usr/bin/env python3

import os
import subprocess
import sys

from argparse import ArgumentParser
from os import path


root_dir = path.realpath(path.dirname(__file__))
build_dir = path.join(root_dir, "build")
tools_dir = path.join(root_dir, "tools")


def print_usage():
    print("USAGE:")
    print(f"    ${sys.argv[0]} COMMAND [OPTIONS]")
    print()
    print("COMMANDS:")
    print("    help, h     Display this message")
    print("    build, b    Build all components")
    print("        --run, -r   Run the image after building it")
    print("    run, r      Run previously built image")


def parse_build_options(arguments):
    options = {
        "run": False,
    }

    for arg in arguments:
        if arg in ["--run", "-r"]:
            options["run"] = True

        else:
            print(
                f'error: invalid argument for command "{command}": "{arg}"',
                file=sys.stderr,
            )
            exit(1)

    return options


def execute_build_command():
    subprocess.run(
        ["make", "mbr"],
        check=True,
        cwd=path.join(root_dir, "loader"),
        env=os.environ
        | {
            "SOURCE_DIR": path.join(root_dir, "loader"),
            "OUTPUT_DIR": path.join(build_dir, "loader"),
        },
    )

    subprocess.run(
        [path.join(tools_dir, "make-disk-image.sh"), build_dir, "wisteria-os.img"]
    )


def execute_run_command():
    image_path = path.join(build_dir, "wisteria-os.img")
    subprocess.run(
        ["qemu-system-x86_64", "-drive", f"format=raw,file={image_path}"],
        check=True,
    )


if __name__ == "__main__":
    if len(sys.argv) == 1:
        print_usage()
        exit(1)

    command = sys.argv[1]
    arguments = sys.argv[2:]

    try:
        if command in ["help", "h", "--help", "-h"]:
            print_usage()
            exit(1)

        elif command in ["build", "b"]:
            options = parse_build_options(arguments)
            execute_build_command()

            if options["run"]:
                execute_run_command()

        elif command in ["run", "r"]:
            execute_run_command()

        else:
            print(f'error: invalid command "{command}"', file=sys.stderr)
            exit(1)

    except subprocess.CalledProcessError:
        print("error: task failed", file=sys.stderr)
        exit(1)
