import socket
import json
import subprocess
import os

# Command to get the active window title
# Create a socket connection
socket_path = f"/tmp/hypr/{os.getenv('HYPRLAND_INSTANCE_SIGNATURE')}/.socket2.sock"
with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
    print(socket_path)
    s.connect(socket_path)

    # Read and print the socket output
    while True:
        data = s.recv(1024)
        if not data:
            break
        #print(data.decode().split(">>")[1])
        if (data.decode().split(">>")[0] == "activewindow"):
            sdata = data.decode("utf-8").strip().split(">>")[1]
            print(json.dumps(
                {"execname" : sdata.split(",")[0], 
                "title" : sdata.split(",")[1]}))
