docker run -p 8384:8384 -p 22000:22000 --name mysyncthing --restart=always -d -v /wherever/st-sync:/var/syncthing syncthing/syncthing:latest