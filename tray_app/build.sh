CGO_ENABLED=1 go build -buildvcs=false -trimpath -ldflags "-s -w" -o focusd-tray .

sudo install -m 0755 ./focusd-tray /usr/local/bin/focusd-tray

# https://chatgpt.com/c/689689df-48b8-8324-8fc6-5c45fb6ce9b0