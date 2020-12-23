FROM ghcr.io/classofcode/coder:latest

CMD /usr/local/bin/code-server --disable-telemetry --bind-addr 0.0.0.0:$PORT /home/coder/